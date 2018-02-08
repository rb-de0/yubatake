import Configs

struct FileConfig: ConfigInitializable {
    
    struct ResourceGroup {
        let rootDir: String
        let relativePath: String
        let fileExtension: String
        let groupName: String
        let ignoreDirectory: String?
    }
    
    let publicDir: String
    let viewsDir: String
    
    let imageRelativePath = "documents/imgs"
    let imageDir: String
    let userRelativePath = "user"
    let userPublicDir: String
    let userViewDir: String
    
    let scriptConfig: ResourceGroup
    let styleConfig: ResourceGroup
    let viewConfig: ResourceGroup
    
    init(config: Config) throws {
        
        publicDir = config.publicDir
        viewsDir = config.viewsDir
        
        imageDir = publicDir.finished(with: "/") + imageRelativePath
        userPublicDir = publicDir.finished(with: "/") + userRelativePath
        userViewDir = viewsDir.finished(with: "/") + userRelativePath
        
        scriptConfig = ResourceGroup(rootDir: publicDir, relativePath: "js", fileExtension: "js", groupName: "JavaScript", ignoreDirectory: nil)
        styleConfig = ResourceGroup(rootDir: publicDir, relativePath: "styles", fileExtension: "css", groupName: "CSS", ignoreDirectory: nil)
        viewConfig = ResourceGroup(rootDir: viewsDir, relativePath: "", fileExtension: "leaf", groupName: "View", ignoreDirectory: userRelativePath)
    }
}
