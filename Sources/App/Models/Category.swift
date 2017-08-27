import Vapor
import FluentProvider
import HTTP

final class Category: Model {
    
    let storage = Storage()
    
    var name: String
    
    static let idKey = "id"
    static let nameKey = "name"
    
    init(name: String) {
        self.name = name
    }
    
    init(row: Row) throws {
        name = try row.get(Category.nameKey)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Category.nameKey, name)
        return row
    }
}

// MARK: - Preparation
extension Category: Preparation {
    
    static func prepare(_ database: Database) throws {
        
        try database.create(self) { builder in
            builder.id()
            builder.string(Category.nameKey)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: - JSONRepresentable
extension Category: JSONRepresentable {
    
    func makeJSON() throws -> JSON {
        var row = try makeRow()
        try row.set(Category.idKey, id)
        return JSON(row)
    }
}

// MARK: - ResponseRepresentable
extension Category: ResponseRepresentable {}

// MARK: - Relation
extension Category {
    
    var posts: Children<Category, Post> {
        return children()
    }
}
