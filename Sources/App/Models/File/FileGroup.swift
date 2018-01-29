import Foundation

struct FileGroup {
    
    let rootPath: String
    let groupPath: String
    let searchPath: String
    let ext: String
    let customized: Bool
    
    private(set) var files = [File]()
    
    init(rootPath: String, groupPath: String, searchPath: String, ext: String, customized: Bool, ignoring ignoreDirectory: String? = nil) {
        self.rootPath = rootPath
        self.groupPath = NSString(string: rootPath.finished(with: "/") + groupPath).standardizingPath
        self.searchPath = NSString(string: self.groupPath.finished(with: "/") + searchPath).standardizingPath
        self.ext = ext
        self.customized = customized
        self.files = searchFiles(in: self.searchPath, ext: ext, ignoring: ignoreDirectory)
    }
    
    private func searchFiles(in directory: String, ext: String, ignoring ignoreDirectory: String?) -> [File] {
        
        let contents = FileManager.default.contents(in: directory)
        
        let directories = contents.filter { $0.isDir }.filter { $0.name != ignoreDirectory }
        let targetFiles = contents.filter { !$0.isDir }.filter { $0.name.hasSuffix(ext) }
        
        return targetFiles + directories.flatMap { searchFiles(in: $0.fullPath, ext: ext, ignoring: nil) }
    }
}

