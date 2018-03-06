import Configs

struct FileConfig: ConfigInitializable {
    
    // Constant
    let imageRelativePath = "documents/imgs"
    let userRelativePath = "user"
    let themeRelativePath = "theme"
    let viewRelativePath = "Views"
    let publicRelativePath = "Public"
    
    let scriptGroupName = "JavaScript"
    let styleGroupName = "Styles"
    let viewGroupName = "Template(leaf)"
    
    let scriptSubDir = "js"
    let styleSubDir = "styles"
    
    let scriptExtension = "js"
    let styleExtension = "css"
    let viewExtension = "leaf"
    
    let workDir: String
    let publicDir: String
    let viewsDir: String
    
    let imageDir: String
    let themeDir: String
    let userPublicDir: String
    let userViewDir: String
    
    init(config: Config) throws {
        
        workDir = config.workDir
        publicDir = config.publicDir
        viewsDir = config.viewsDir
        
        imageDir = publicDir.finished(with: "/") + imageRelativePath
        userPublicDir = publicDir.finished(with: "/") + userRelativePath
        userViewDir = viewsDir.finished(with: "/") + userRelativePath
        themeDir = workDir.finished(with: "/") + themeRelativePath
    }
}
