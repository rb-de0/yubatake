import Vapor

final class AccessibleFileGroup: JSONRepresentable {
    
    static let nameKey = "name"
    static let fileListKey = "files"
    
    let name: String
    let files: [AccessibleFile]
    
    init(name: String, files: [AccessibleFile]) {
        self.name = name
        self.files = files
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(AccessibleFileGroup.nameKey, name)
        try json.set(AccessibleFileGroup.fileListKey, files.makeJSON())
        return json
    }
    
    class func make(from files: [File], name: String, type: FileType, rootDir: String) -> AccessibleFileGroup {
        
        var accessibleFiles = [AccessibleFile]()
        
        for file in files {
            
            let relativePath = String(file.fullPath.dropFirst(rootDir.count)).started(with: "/")
            
            if accessibleFiles.contains(where: { $0.relativePath == relativePath }) {
                continue
            }
            
            accessibleFiles.append(AccessibleFile(name: file.name, type: type, relativePath: relativePath))
        }
        
        accessibleFiles.sort(by: { $0.name < $1.name })
        
        return AccessibleFileGroup(name: name, files: accessibleFiles)
    }
}
