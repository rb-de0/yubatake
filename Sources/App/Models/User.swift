import Vapor
import FluentProvider
import HTTP

final class User: Model {
    
    let storage = Storage()
    
    var name: String
    var password: String
    
    static let idKey = "id"
    static let nameKey = "name"
    static let passwordKey = "password"
    
    init(name: String, password: String) {
        self.name = name
        self.password = password
    }
    
    init(row: Row) throws {
        name = try row.get(User.nameKey)
        password = try row.get(User.passwordKey)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(User.nameKey, name)
        try row.set(User.passwordKey, password)
        return row
    }
}

// MARK: - Preparation
extension User: Preparation {
    
    static func prepare(_ database: Database) throws {
        
        try database.create(self) { builder in
            builder.id()
            builder.string(User.nameKey)
            builder.string(User.passwordKey)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: - JSONRepresentable
extension User: JSONRepresentable {
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(User.idKey, id)
        try json.set(User.nameKey, name)
        return json
    }
}

// MARK: - ResponseRepresentable
extension User: ResponseRepresentable {}

// MARK: - Relation
extension User {
    
    var posts: Children<User, Post> {
        return children()
    }
}
