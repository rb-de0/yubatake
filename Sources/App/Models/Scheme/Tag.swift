import FluentProvider
import HTTP
import ValidationProvider
import Vapor

final class Tag: Model {
    
    static let idKey = "id"
    static let nameKey = "name"
    static let tagsKey = "tags"
    static let separator = ","
    
    let storage = Storage()
    
    var name: String
    
    init(request: Request) throws {
        
        name = request.data[Tag.nameKey]?.string ?? ""
        
        try validate()
    }
    
    private init(name: String) {
        self.name = name
    }

    init(row: Row) throws {
        name = try row.get(Tag.nameKey)
    }
    
    func validate() throws {
        try name.validated(by: Count.containedIn(low: 1, high: 16))
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Tag.nameKey, name)
        return row
    }
    
    // MARK: - Helper
    
    static func tags(from request: Request) throws -> [Tag] {
        guard let tagString = request.data[Tag.tagsKey]?.string else {
            return []
        }
        
        let tagStrings = tagString.components(separatedBy: Tag.separator)
        return tagStrings.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.map { Tag(name: $0) }
    }
    
    static func notInsertedTags(in tags: [Tag]) throws -> [Tag] {
        return try tags.filter { try Tag.makeQuery().filter(Tag.nameKey == $0.name).count() == 0 }
    }
    
    static func insertedTags(in tags: [Tag]) throws -> [Tag] {
        return try tags.flatMap { try Tag.makeQuery().filter(Tag.nameKey == $0.name).first() }
    }
}

// MARK: - Preparation
extension Tag: Preparation {
    
    static func prepare(_ database: Database) throws {
        
        try database.create(self) { builder in
            builder.id()
            builder.string(Tag.nameKey, unique: true)
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

// MARK: - Timestampable
extension Tag: Timestampable {}

// MARK: - Paginatable
extension Tag: Paginatable {}


// MARK: - Updateable
extension Tag: Updateable {
    
    func update(for req: Request) throws {
        
        name = req.data[Tag.nameKey]?.string ?? ""
        
        try validate()
    }
    
    static var updateableKeys: [UpdateableKey<Tag>] {
        return []
    }
}
