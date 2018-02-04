import Foundation
import Vapor

final class FileHelper: ApplicationHelper {
    
    private static var publicDir: String!
    private static var viewDir: String!
    private static var userViewDir: String!
    private static var userPublicDir: String!
    private static var imageDir: String!
    
    private static var scriptConfig: FileConfig!
    private static var styleConfig: FileConfig!
    private static var viewConfig: FileConfig!
    
    static var userRelativePath: String!
    static var imageRelativePath: String!
    
    static func setup(_ drop: Droplet) throws {
        
        publicDir = drop.config.publicDir
        viewDir = drop.config.viewsDir
        userViewDir = drop.config.userViewDir
        userPublicDir = drop.config.userPublicDir
        imageDir = drop.config.imageDir
        
        scriptConfig = drop.config.scriptConfig
        styleConfig = drop.config.styleConfig
        viewConfig = drop.config.viewConfig
        
        userRelativePath = drop.config.userRelativePath
        imageRelativePath = drop.config.imageRelativePath
        
        try createImageDirIfNeeded()
    }
    
    class func isExist(path: String) -> Bool {
        return FileManager.default.fileExists(atPath: publicDir.finished(with: "/") + path)
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
    
    class func renameImage(at path: String, to afterPath: String) throws {
        try FileManager.default.moveItem(atPath: publicDir.finished(with: "/") + path, toPath: publicDir.finished(with: "/") + afterPath)
    }
    
    private class func createImageDirIfNeeded() throws {
        try FileManager.default.createDirectory(atPath: imageDir, withIntermediateDirectories: true, attributes: nil)
    }
}

// MARK: - File
extension FileHelper {
    
    class func accessibleFiles() -> [AccessibleFileGroup] {
        
        let scriptGroups = [
            FileGroup(config: scriptConfig),
            FileGroup(config: scriptConfig, userPath: userRelativePath)
        ]
        
        let scriptGroup = AccessibleFileGroup.make(from: scriptGroups, with: scriptConfig.groupName, type: .publicResource)

        let styleGroups = [
            FileGroup(config: styleConfig),
            FileGroup(config: styleConfig, userPath: userRelativePath)
        ]
        
        let styleGroup = AccessibleFileGroup.make(from: styleGroups, with: styleConfig.groupName, type: .publicResource)
        
        let viewGroups = [
            FileGroup(config: viewConfig),
            FileGroup(config: viewConfig, userPath: userRelativePath)
        ]
        
        let viewGroup = AccessibleFileGroup.make(from: viewGroups, with: viewConfig.groupName, type: .view)
        
        return [scriptGroup, styleGroup, viewGroup]
    }
}

// MARK: I/O
extension FileHelper {
    
    private class func userDir(at type: FileType) -> String {
        return type == .view ? userViewDir : userPublicDir
    }
    
    class func writeUserFileData(at path: String, type: FileType, data: String) throws {
        
        guard let data = data.data(using: .utf8) else {
            throw Abort(.badRequest)
        }
        
        let path = (userDir(at: type).finished(with: "/") + path).normalized()
        let url = URL(fileURLWithPath: path)
        
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: url.absoluteString) {
            try data.write(to: url)
        } else {
            let dir = path.deletingLastPathComponent
            if !fileManager.fileExists(atPath: dir) {
                try fileManager.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
            }
            fileManager.createFile(atPath: path, contents: data, attributes: nil)
        }
    }
    
    class func deleteUserFileData(at path: String, type: FileType) throws {
        let path = (userDir(at: type).finished(with: "/") + path).normalized()
        try FileManager.default.removeItem(atPath: path)
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
