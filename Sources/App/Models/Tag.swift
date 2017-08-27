import Vapor
import FluentProvider
import HTTP

final class Tag: Model {
    
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
extension Tag: Preparation {
    
    static func prepare(_ database: Database) throws {
        
        try database.create(self) { builder in
            builder.id()
            builder.string(Tag.nameKey)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: - JSONRepresentable
extension Tag: JSONRepresentable {
    
    func makeJSON() throws -> JSON {
        var row = try makeRow()
        try row.set(Tag.idKey, id)
        return JSON(row)
    }
}

// MARK: - ResponseRepresentable
extension Tag: ResponseRepresentable {}

// MARK: - Relation
extension Tag {

    var posts: Siblings<Tag, Post, Pivot<Tag, Post>> {
        return siblings()
    }
}
