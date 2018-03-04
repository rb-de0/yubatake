import Vapor

struct AccessibleFileGroup: JSONRepresentable {
    
    static let nameKey = "name"
    static let fileListKey = "files"
    
    let name: String
    let files: [AccessibleFile]
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(AccessibleFileGroup.nameKey, name)
        try json.set(AccessibleFileGroup.fileListKey, files.makeJSON())
        return json
    }
    
    static func make(from files: [File], name: String, type: FileType, rootDir: String, theme: String?) -> AccessibleFileGroup {
        
        let repository = resolve(FileRepository.self)
        
        var accessibleFiles = [AccessibleFile]()
        
        for file in files {
            
            let relativePath = String(file.fullPath.dropFirst(rootDir.count)).started(with: "/")
            
            if accessibleFiles.contains(where: { $0.relativePath == relativePath }) {
                continue
            }
            
            let customized = theme == nil && (try? repository.readFileData(in: theme, at: relativePath, type: type, customized: true)) != nil
            let accessibleFile = AccessibleFile(name: file.name, type: type, relativePath: relativePath, customized: customized, theme: theme)
            accessibleFiles.append(accessibleFile)
        }
        
        accessibleFiles.sort(by: { $0.name < $1.name })
        
        return AccessibleFileGroup(name: name, files: accessibleFiles)
    }
}
