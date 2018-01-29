import Foundation

struct File {
    let fullPath: String
    let name: String
    
    init(fullPath: String, name: String) {
        self.fullPath = NSString(string: fullPath).standardizingPath
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

extension FileManager {
    
    func contents(in directory: String) -> [File] {
        let contents = (try? contentsOfDirectory(atPath: directory)) ?? []
        return contents.map { File(fullPath: directory.finished(with: "/") + $0, name: $0) }
    }
}
