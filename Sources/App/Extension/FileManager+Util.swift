import Foundation

extension FileManager {
    
    struct File {
        
        let name: String
        let absolutePath: String
        
        var isDirPath: Bool {
            var isDir = ObjCBool(false)
            FileManager.default.fileExists(atPath: absolutePath, isDirectory: &isDir)
            
            #if os(Linux)
            return isDir
            #else
            return isDir.boolValue
            #endif
        }
    }
    
    func dirExists(atPath path: String) -> Bool {
        
        var isDir = ObjCBool(false)
        let exist = fileExists(atPath: path, isDirectory: &isDir)
        
        #if os(Linux)
        return isDir && exist
        #else
        return isDir.boolValue && exist
        #endif
    }
    
    func enumerateFiles(in path: String, hasExtension ext: String) throws -> [File] {
        
        let contents = try contentsOfDirectory(atPath: path)
            .map { File(name: $0, absolutePath: path.finished(with: "/").appending($0)) }
        
        let directories = contents.filter { $0.isDirPath }
        let files = contents.filter { !$0.isDirPath }.filter { $0.name.hasSuffix(ext) }
        let nestedFiles = try directories.flatMap { try enumerateFiles(in: $0.absolutePath, hasExtension: ext) }
        
        return files + nestedFiles
    }
}
