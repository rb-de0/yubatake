import Foundation

struct FileGroup {
    
    struct File {
        let fullPath: String
        let name: String
        
        init(fullPath: String, name: String) {
            self.fullPath = fullPath.normalized()
            self.name = name
        }
        
        var isDir: Bool {
            var isDir = ObjCBool(false)
            FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDir)
            
            #if os(Linux)
                return isDir
            #else
                return isDir.boolValue
            #endif
        }
    }
    
    let rootDir: String
    let groupDir: String
    let customized: Bool
    
    private(set) var files = [File]()
    
    init(config: FileConfig, userPath: String = "") {
        
        rootDir = config.rootDir
        groupDir = (rootDir.finished(with: "/") + userPath).normalized()
        customized = !userPath.isEmpty
        
        let searchPath = (groupDir.finished(with: "/") + config.relativePath).normalized()
        files = searchFiles(in: searchPath, ext: config.fileExtension, ignoring: config.ignoreDirectory)
    }
    
    private func searchFiles(in directory: String, ext: String, ignoring ignoreDirectory: String?) -> [File] {
        
        let contents = FileManager.default.contents(in: directory)
        
        let directories = contents.filter { $0.isDir }.filter { $0.name != ignoreDirectory }
        let targetFiles = contents.filter { !$0.isDir }.filter { $0.name.hasSuffix(ext) }
        
        return targetFiles + directories.flatMap { searchFiles(in: $0.fullPath, ext: ext, ignoring: nil) }
    }
}

extension FileManager {
    
    func contents(in directory: String) -> [FileGroup.File] {
        let contents = (try? contentsOfDirectory(atPath: directory)) ?? []
        return contents.map { FileGroup.File(fullPath: directory.finished(with: "/") + $0, name: $0) }
    }
}
