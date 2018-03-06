import Vapor

struct AccessibleFile: JSONRepresentable {
    
    static let nameKey = "name"
    static let typeKey = "type"
    static let pathKey = "path"
    static let customizedKey = "customized"
    static let themeKey = "theme"

    let name: String
    let type: FileType
    let relativePath: String
    let customized: Bool
    let theme: String?
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(AccessibleFile.nameKey, name)
        try json.set(AccessibleFile.typeKey, type.rawValue)
        try json.set(AccessibleFile.pathKey, relativePath)
        try json.set(AccessibleFile.customizedKey, customized)
        try json.set(AccessibleFile.themeKey, theme)
        return json
    }
}
