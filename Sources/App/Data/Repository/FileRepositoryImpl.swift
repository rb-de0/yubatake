import Foundation
import Vapor

final class FileRepositoryImpl: FileRepository, FileHandlable {
    
    let config: FileConfig
    let fm = FileManager.default
    
    init() {
        
        config = Configs.resolve(FileConfig.self)
        
        do {
            try createDirIfNeeded()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    // MARK: - User Files
    
    func readFileData(in theme: String?, at path: String, type: FileType, customized: Bool) throws -> String {
        
        try verifyPath(path)
        
        let _filePath: String
        
        switch (theme, customized) {
        case (let theme?, _):
            _filePath = themeFilePath(in: theme, at: path, type: type)
        case (_, true):
            _filePath = userFilePath(at: path, type: type)
        case (_, false):
            _filePath = filePath(at: path, type: type)
        }
        
        guard let fileData = fm.contents(atPath: _filePath),
            let fileString = String(data: fileData, encoding: .utf8) else {
                
            throw Abort(.notFound)
        }
        
        return fileString
    }
    
    func writeUserFileData(at path: String, type: FileType, data: String) throws {
        
        try verifyPath(path)
        
        guard let data = data.data(using: .utf8) else {
            throw Abort(.badRequest)
        }
        
        let path = userFilePath(at: path, type: type)
        let url = URL(fileURLWithPath: path)
        
        if fm.fileExists(atPath: url.absoluteString) {
            try data.write(to: url)
        } else {
            let dir = path.deletingLastPathComponent
            if !fm.fileExists(atPath: dir) {
                try fm.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
            }
            fm.createFile(atPath: path, contents: data, attributes: nil)
        }
    }
    
    func deleteUserFileData(at path: String, type: FileType) throws {
        
        try verifyPath(path)
        
        let path = userFilePath(at: path, type: type)
        try fm.removeItem(atPath: path)
    }
    
    func deleteAllUserFiles() throws {
        try fm.removeItemIfExist(atPath: config.userPublicDir)
        try fm.removeItemIfExist(atPath: config.userViewDir)
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
        return fm.contents(in: config.themeDir).filter { $0.isDir }.flatMap { $0.name }
    }
    
    func saveTheme(as name: String) throws {
        
        let themeDir = themeDirPath(for: name)
        
        try fm.removeItemIfExist(atPath: themeDir)
        try fm.createDirectory(atPath: themeDir, withIntermediateDirectories: true, attributes: nil)
        
        try fm.copyItemIfExist(atPath: config.userPublicDir, toPath: themeSubDir(in: name, type: .publicResource))
        try fm.copyItemIfExist(atPath: config.userViewDir, toPath: themeSubDir(in: name, type: .view))
    }
    
    func copyTheme(name: String) throws {

        try fm.removeItemIfExist(atPath: config.userPublicDir)
        try fm.removeItemIfExist(atPath: config.userViewDir)
        
        try fm.copyItemIfExist(atPath: themeSubDir(in: name, type: .publicResource), toPath: config.userPublicDir)
        try fm.copyItemIfExist(atPath: themeSubDir(in: name, type: .view), toPath: config.userViewDir)
    }
    
    func deleteTheme(name: String) throws {
        try fm.removeItemIfExist(atPath: themeDirPath(for: name))
    }
    
    // MARK: - Private
    
    private func createDirIfNeeded() throws {
        try fm.createDirectory(atPath: config.imageDir, withIntermediateDirectories: true, attributes: nil)
    }
}
