import Vapor

struct FileConfig: Service {
    
    let publicRoot = "Public"
    let themeRoot = "themes"
    let imageRoot = "documents/imgs"
    
    let workDir: String
    let publicDir: String
    let themeDir: String
    let imageDir: String
    
    init(directoryConfig: DirectoryConfig) {
        workDir = directoryConfig.workDir
        publicDir = workDir.finished(with: "/").appending(publicRoot)
        themeDir = publicDir.finished(with: "/").appending(themeRoot)
        imageDir = publicDir.finished(with: "/").appending(imageRoot)
    }
    
    func templateDir(in theme: String) -> String {
        return themeDir.finished(with: "/")
            .appending(theme).finished(with: "/")
            .appending("template").finished(with: "/")
    }
}
