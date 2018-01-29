import Foundation
import Vapor

final class FileHelper: ApplicationHelper {
    
    static let imageRelativePath = "/documents/imgs"
    static let userRelativePath = "/user"
    static let userDirectoryName = "user"
    
    static let styleRelativePath = "/styles"
    static let styleExtension = "css"
    static let styleGroupName = "CSS"
    
    static let scriptRelativePath = "/js"
    static let scriptExtension = "js"
    static let scriptGroupName = "JavaScript"
    
    static let viewExtension = "leaf"
    static let viewGroupName = "View"
    
    static var publicDir: String!
    static var viewDir: String!
    
    static func setup(_ drop: Droplet) throws {
        publicDir = drop.config.publicDir
        viewDir = drop.config.viewsDir
        
        try createImageDirIfNeeded()
    }
}

// MARK: - Image
extension FileHelper {
    
    class func saveImage(data: Data, at path: String) throws {
        
        let result = FileManager.default.createFile(atPath: publicDir.finished(with: "/") + path, contents: data, attributes: nil)
        
        guard result else {
            throw IOError.sameNameAlreadyExist
        }
    }
    
    class func deleteImage(at path: String) throws {
        try FileManager.default.removeItem(atPath: publicDir.finished(with: "/") + path)
    }
    
    private class func createImageDirIfNeeded() throws {
        try FileManager.default.createDirectory(atPath: publicDir.finished(with: "/") + imageRelativePath, withIntermediateDirectories: true, attributes: nil)
    }
}

// MARK: - File
extension FileHelper {
    
    class func accessibleFiles() -> [AccessibleFileGroup] {
        
        let scriptGroups = [
            FileGroup(rootPath: publicDir, groupPath: "", searchPath: scriptRelativePath, ext: scriptExtension, customized: false),
            FileGroup(rootPath: publicDir, groupPath: userRelativePath, searchPath: scriptRelativePath, ext: scriptExtension, customized: true)
        ]
        
        let scriptGroup = AccessibleFileGroup.make(from: scriptGroups, with: scriptGroupName, type: .publicResource)

        let styleGroups = [
            FileGroup(rootPath: publicDir, groupPath: "", searchPath: styleRelativePath, ext: styleExtension, customized: false),
            FileGroup(rootPath: publicDir, groupPath: userRelativePath, searchPath: styleRelativePath, ext: styleExtension, customized: true)
        ]
        
        let styleGroup = AccessibleFileGroup.make(from: styleGroups, with: styleGroupName, type: .publicResource)
        
        let viewGroups = [
            FileGroup(rootPath: viewDir, groupPath: "", searchPath: "", ext: viewExtension, customized: false, ignoring: userDirectoryName),
            FileGroup(rootPath: viewDir, groupPath: userRelativePath, searchPath: "", ext: viewExtension, customized: true)
        ]
        
        let viewGroup = AccessibleFileGroup.make(from: viewGroups, with: viewGroupName, type: .view)
        
        return [scriptGroup, styleGroup, viewGroup]
    }
    
    class func writeUserFileData(at path: String, type: FileType, data: String) throws {
        
        guard let data = data.data(using: .utf8) else {
            throw Abort(.badRequest)
        }
        
        let userDirectoryPath = type == .view ? viewDir + userRelativePath : publicDir + userRelativePath
        let path = NSString(string: userDirectoryPath.finished(with: "/") + path).standardizingPath
        let url = URL(fileURLWithPath: path)
        
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: url.absoluteString) {
            try data.write(to: url)
        } else {
            let dir = (path as NSString).deletingLastPathComponent
            if !fileManager.fileExists(atPath: dir) {
                try fileManager.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
            }
            fileManager.createFile(atPath: path, contents: data, attributes: nil)
        }
    }
    
    class func readFileData(at path: String, type: FileType) throws -> String {
        
        let path = type == .view ? viewDir.finished(with: "/") + path : publicDir.finished(with: "/") + path
        
        guard let fileData = FileManager.default.contents(atPath: path),
            let fileString = String(data: fileData, encoding: .utf8) else {

            throw Abort(.notFound)
        }
        
        return fileString
    }
}
