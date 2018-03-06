import Foundation

final class FileSearcher {
    
    class func search(using rule: FileSearchRule) -> [File] {
        
        func searchFiles(in directory: String, fileExtension: String, ignoring ignoreDirectory: String?) -> [File] {
            
            let contents = FileManager.default.contents(in: directory)
            
            let directories = contents
                .filter { $0.isDir }
                .filter { $0.name != ignoreDirectory }
            
            let files = contents
                .filter { !$0.isDir }
                .filter { $0.name.hasSuffix(fileExtension) }
            
            return files + directories.flatMap { searchFiles(in: $0.fullPath, fileExtension: fileExtension, ignoring: nil) }
        }
        
        return searchFiles(in: rule.searchPath, fileExtension: rule.fileExtension, ignoring: rule.ignoreDir)
    }
}
