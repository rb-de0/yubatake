import Vapor

struct FileConfig {
    let rootDir: String
    let relativePath: String
    let fileExtension: String
    let groupName: String
    let ignoreDirectory: String?
}

extension Config {
    
    var imageRelativePath: String {
        return "documents/imgs"
    }
    
    var imageDir: String {
        return publicDir.finished(with: "/") + imageRelativePath
    }
    
    var userRelativePath: String {
        return "user"
    }
    
    var userPublicDir: String {
        return publicDir.finished(with: "/") + userRelativePath
    }
    
    var userViewDir: String {
        return viewsDir.finished(with: "/") + userRelativePath
    }
    
    var scriptConfig: FileConfig {
        return FileConfig(rootDir: publicDir, relativePath: "js", fileExtension: "js", groupName: "JavaScript", ignoreDirectory: nil)
    }
    
    var styleConfig: FileConfig {
        return FileConfig(rootDir: publicDir, relativePath: "styles", fileExtension: "css", groupName: "CSS", ignoreDirectory: nil)
    }

    var viewConfig: FileConfig {
        return FileConfig(rootDir: viewsDir, relativePath: "", fileExtension: "leaf", groupName: "View", ignoreDirectory: userRelativePath)
    }
}
