import Foundation
import Vapor

final class FileRepositoryImpl: FileRepository {
    
    private let config: FileConfig
    
    init() {
        
        config = Configs.resolve(FileConfig.self)
        
        do {
            try createImageDirIfNeeded()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func isExist(path: String) -> Bool {
        return FileManager.default.fileExists(atPath: config.publicDir.finished(with: "/") + path)
    }
}

// MARK: - Image
extension FileRepositoryImpl {
    
    func saveImage(data: Data, at path: String) throws {
        
        let result = FileManager.default.createFile(atPath: config.publicDir.finished(with: "/") + path, contents: data, attributes: nil)
        
        guard result else {
            throw IOError.sameNameAlreadyExist
        }
    }
    
    func deleteImage(at path: String) throws {
        try FileManager.default.removeItem(atPath: config.publicDir.finished(with: "/") + path)
    }
    
    func renameImage(at path: String, to afterPath: String) throws {
        try FileManager.default.moveItem(atPath: config.publicDir.finished(with: "/") + path, toPath: config.publicDir.finished(with: "/") + afterPath)
    }
    
    private func createImageDirIfNeeded() throws {
        try FileManager.default.createDirectory(atPath: config.imageDir, withIntermediateDirectories: true, attributes: nil)
    }
}

// MARK: - File
extension FileRepositoryImpl {
    
    func accessibleFiles() -> [AccessibleFileGroup] {
        
        let scriptGroups = [
            FileFinder.find(group: config.scriptConfig),
            FileFinder.find(group: config.scriptConfig, userPath: config.userRelativePath)
        ]
        
        let scriptGroup = AccessibleFileGroup.make(from: scriptGroups, with: config.scriptConfig.groupName, type: .publicResource)

        let styleGroups = [
            FileFinder.find(group: config.styleConfig),
            FileFinder.find(group: config.styleConfig, userPath: config.userRelativePath)
        ]
        
        let styleGroup = AccessibleFileGroup.make(from: styleGroups, with: config.styleConfig.groupName, type: .publicResource)
        
        let viewGroups = [
            FileFinder.find(group: config.viewConfig),
            FileFinder.find(group: config.viewConfig, userPath: config.userRelativePath)
        ]
        
        let viewGroup = AccessibleFileGroup.make(from: viewGroups, with: config.viewConfig.groupName, type: .view)
        
        return [scriptGroup, styleGroup, viewGroup]
    }
}

// MARK: I/O
extension FileRepositoryImpl {
    
    private func userDir(at type: FileType) -> String {
        return type == .view ? config.userViewDir : config.userPublicDir
    }
    
    func writeUserFileData(at path: String, type: FileType, data: String) throws {
        
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
    
    func deleteUserFileData(at path: String, type: FileType) throws {
        let path = (userDir(at: type).finished(with: "/") + path).normalized()
        try FileManager.default.removeItem(atPath: path)
    }
    
    func readFileData(at path: String, type: FileType) throws -> String {
        
        let path = type == .view ? config.viewsDir.finished(with: "/") + path : config.publicDir.finished(with: "/") + path
        
        guard let fileData = FileManager.default.contents(atPath: path),
            let fileString = String(data: fileData, encoding: .utf8) else {
                
            throw Abort(.notFound)
        }
        
        return fileString
    }
}
