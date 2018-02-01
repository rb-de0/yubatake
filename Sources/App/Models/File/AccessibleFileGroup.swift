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
    
    class func make(from groups: [FileGroup], with name: String, type: FileType) -> AccessibleFileGroup {
        
        var accessibleFiles = [AccessibleFile]()
        
        for group in groups {
            
            for file in group.files {
                
                let relativePath = String(file.fullPath.dropFirst(group.groupDir.count)).started(with: "/")
                let relativePathToRoot = String(file.fullPath.dropFirst(group.rootDir.count)).started(with: "/")
                
                if let existFile = accessibleFiles.first(where: { $0.relativePath == relativePath  }) {
                    if group.customized {
                        existFile.userPathToRoot = relativePathToRoot
                    } else {
                        existFile.originalPathToRoot = relativePathToRoot
                    }
                    continue
                }
                
                if group.customized {
                    accessibleFiles.append(AccessibleFile(name: file.name, type: type, relativePath: relativePath, userPathToRoot: relativePathToRoot))
                } else {
                    accessibleFiles.append(AccessibleFile(name: file.name, type: type, relativePath: relativePath, originalPathToRoot: relativePathToRoot))
                }
            }
        }
        
        return AccessibleFileGroup(name: name, files: accessibleFiles)
    }
}
