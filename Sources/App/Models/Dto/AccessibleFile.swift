import Vapor

final class AccessibleFile: JSONRepresentable {
    
    static let nameKey = "name"
    static let typeKey = "type"
    static let pathKey = "path"
    static let originalPathKey = "original_path"
    static let userPathKey = "user_path"

    let name: String
    let type: FileType
    let relativePath: String
    var originalPathToRoot: String?
    var userPathToRoot: String?
    
    init(name: String, type: FileType, relativePath: String, originalPathToRoot: String? = nil, userPathToRoot: String? = nil) {
        self.name = name
        self.type = type
        self.relativePath = relativePath
        self.originalPathToRoot = originalPathToRoot
        self.userPathToRoot = userPathToRoot
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(AccessibleFile.nameKey, name)
        try json.set(AccessibleFile.typeKey, type.rawValue)
        try json.set(AccessibleFile.pathKey, relativePath)
        return json
    }
}
