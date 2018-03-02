
protocol FileHandlable {
    var config: FileConfig { get }
}

extension FileHandlable {
    
    func userFilePath(at path: String, type: FileType) -> String {
        let dirPath = type == .view ? config.userViewDir : config.userPublicDir
        return (dirPath.finished(with: "/") + path).normalized()
    }
    
    func filePath(at path: String, type: FileType) -> String {
        let dirPath = type == .view ? config.viewsDir : config.publicDir
        return (dirPath.finished(with: "/") + path).normalized()
    }
    
    func themeDirPath(for name: String) -> String {
        return config.themeDir.finished(with: "/") + name
    }
    
    func themeSubDir(in theme: String, type: FileType) -> String {
        let themeDir = themeDirPath(for: theme)
        let dirPath = type == .view ? config.viewRelativePath : config.publicRelativePath
        return themeDir.finished(with: "/") + dirPath
    }
    
    func themeFilePath(in theme: String, at path: String, type: FileType) -> String {
        return themeSubDir(in: theme, type: type).finished(with: "/") + path
    }
}
