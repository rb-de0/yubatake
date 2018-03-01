import Vapor

final class AccessibleFile: JSONRepresentable {
    
    static let nameKey = "name"
    static let typeKey = "type"
    static let pathKey = "path"

    let name: String
    let type: FileType
    let relativePath: String
    
    init(name: String, type: FileType, relativePath: String) {
        self.name = name
        self.type = type
        self.relativePath = relativePath
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(AccessibleFile.nameKey, name)
        try json.set(AccessibleFile.typeKey, type.rawValue)
        try json.set(AccessibleFile.pathKey, relativePath)
        return json
    }
}
