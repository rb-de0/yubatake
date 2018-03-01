import Foundation
import Vapor

final class FileRepositoryImpl: FileRepository, FileHandlable {
    
    let config: FileConfig
    
    init() {
        
        config = Configs.resolve(FileConfig.self)
        
        do {
            try createDirIfNeeded()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    // MARK: - User Files
    
    func readFileData(at path: String, type: FileType) throws -> String {
        
        let path = filePath(at: path, type: type)
        
        guard let fileData = FileManager.default.contents(atPath: path),
            let fileString = String(data: fileData, encoding: .utf8) else {
                
            throw Abort(.notFound)
        }
        
        return fileString
    }
    
    func readUserFileData(at path: String, type: FileType) throws -> String {
        
        let path = userFilePath(at: path, type: type)
        
        guard let fileData = FileManager.default.contents(atPath: path),
            let fileString = String(data: fileData, encoding: .utf8) else {
                
            throw Abort(.notFound)
        }
        
        return fileString
    }
    
    func writeUserFileData(at path: String, type: FileType, data: String) throws {
        
        guard let data = data.data(using: .utf8) else {
            throw Abort(.badRequest)
        }
        
        let path = userFilePath(at: path, type: type)
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
        let path = userFilePath(at: path, type: type)
        try FileManager.default.removeItem(atPath: path)
    }
    
    func deleteAllUserFiles() throws {
        let fileManager = FileManager.default
        try fileManager.removeItemIfExist(atPath: config.userPublicDir)
        try fileManager.removeItemIfExist(atPath: config.userViewDir)
    }
    
    
    func readThemeFileData(in theme: String, at path: String, type: FileType) throws -> String {
        
        let path = themeFilePath(in: theme, at: path, type: type)
        
        guard let fileData = FileManager.default.contents(atPath: path),
            let fileString = String(data: fileData, encoding: .utf8) else {
                
            throw Abort(.notFound)
        }
        
        return fileString
    }
    
    // MARK: - Theme
    
    func files(in theme: String?) -> [AccessibleFileGroup] {
        
        let publicDir = theme.map { themeSubDir(in: $0, type: .publicResource) } ?? config.publicDir
        let viewDir = theme.map { themeSubDir(in: $0, type: .view) } ?? config.viewsDir
        
        let scriptSearchRule = FileSearchRule(
            rootDir: publicDir,
            subDir: config.scriptSubDir,
            fileExtension: config.scriptExtension,
            ignoreDir: nil
        )
        
        let scriptFiles = FileSearcher.search(using: scriptSearchRule)
        
        let styleSearchRule = FileSearchRule(
            rootDir: publicDir,
            subDir: config.styleSubDir,
            fileExtension: config.styleExtension,
            ignoreDir: nil
        )
        
        let styleFiles = FileSearcher.search(using: styleSearchRule)
        
        let viewSearchRule = FileSearchRule(
            rootDir: viewDir,
            subDir: "",
            fileExtension: config.viewExtension,
            ignoreDir: config.userRelativePath
        )
        
        let viewFiles = FileSearcher.search(using: viewSearchRule)
        
        return [
            AccessibleFileGroup.make(from: scriptFiles, name: config.scriptGroupName, type: .publicResource, rootDir: publicDir),
            AccessibleFileGroup.make(from: styleFiles, name: config.styleGroupName, type: .publicResource, rootDir: publicDir),
            AccessibleFileGroup.make(from: viewFiles, name: config.viewGroupName, type: .view, rootDir: viewDir)
            ].filter { !$0.files.isEmpty }
    }
    
    func getAllThemes() throws -> [String] {
        return FileManager.default.contents(in: config.themeDir).filter { $0.isDir }.flatMap { $0.name }
    }
    
    func saveTheme(as name: String) throws {
        
        let fileManager = FileManager.default
        let themeDir = themeDirPath(for: name)
        
        try fileManager.removeItemIfExist(atPath: themeDir)
        try fileManager.createDirectory(atPath: themeDir, withIntermediateDirectories: true, attributes: nil)
        
        try fileManager.copyItemIfExist(atPath: config.userPublicDir, toPath: themeSubDir(in: name, type: .publicResource))
        try fileManager.copyItemIfExist(atPath: config.userViewDir, toPath: themeSubDir(in: name, type: .view))
    }
    
    func copyTheme(name: String) throws {
        
        let fileManager = FileManager.default
        
        try fileManager.removeItemIfExist(atPath: config.userPublicDir)
        try fileManager.removeItemIfExist(atPath: config.userViewDir)
        
        try fileManager.copyItemIfExist(atPath: themeSubDir(in: name, type: .publicResource), toPath: config.userPublicDir)
        try fileManager.copyItemIfExist(atPath: themeSubDir(in: name, type: .view), toPath: config.userViewDir)
    }
    
    func deleteTheme(name: String) throws {
        
        let fileManager = FileManager.default
        let themeDir = themeDirPath(for: name)
        
        try fileManager.removeItemIfExist(atPath: themeDir)
    }
    
    // MARK: - Private
    
    private func createDirIfNeeded() throws {
        try FileManager.default.createDirectory(atPath: config.imageDir, withIntermediateDirectories: true, attributes: nil)
    }
}
