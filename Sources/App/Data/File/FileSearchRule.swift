
struct FileSearchRule {
    
    let rootDir: String
    let subDir: String
    let fileExtension: String
    let ignoreDir: String?
    
    var searchPath: String {
        return rootDir.finished(with: "/") + subDir
    }
}
