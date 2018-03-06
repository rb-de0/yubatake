import FluentProvider
import HTTP
import ValidationProvider
import Vapor

final class Category: Model {
    
    struct NumberOfPosts: JSONRepresentable {
        let category: Category
        let count: Int
        
        func makeJSON() throws -> JSON {
            var json = JSON()
            try json.set("category", category)
            try json.set("count", count)
            return json
        }
    }
    
    static let idKey = "id"
    static let nameKey = "name"
    
    let storage = Storage()
    
    var name: String
    
    private init(name: String) {
        self.name = name
    }
    
    init(request: Request) throws {
        
        name = request.data[Category.nameKey]?.string ?? ""
        
        try validate()
    }
    
    init(row: Row) throws {
        name = try row.get(Category.nameKey)
    }
    
    func validate() throws {
        try name.validated(by: Count.containedIn(low: 1, high: 32))
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Category.nameKey, name)
        return row
    }
    
    static func makeNonCategorized() -> Category {
        return Category(name: "NonCategorized")
    }
    
    static func numberOfPostsForAll() throws -> [NumberOfPosts] {
        
        return
            try Category.all().flatMap {
                return NumberOfPosts(category: $0, count: try $0.posts.makeQuery().count())
            }
            .filter { $0.count > 0 }
            .sorted(by: { $0.count > $1.count })
    }
}

// MARK: - Preparation
extension Category: Preparation {
    
    static func prepare(_ database: Database) throws {
        
        try database.create(self) { builder in
            builder.id()
            builder.string(Category.nameKey, unique: true)
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

// MARK: - Timestampable
extension Category: Timestampable {}

// MARK: - Paginatable
extension Category: Paginatable {}


// MARK: - Updateable
extension Category: Updateable {
    
    func update(for req: Request) throws {
        
        name = req.data[Category.nameKey]?.string ?? ""
        
        try validate()
    }
    
    static var updateableKeys: [UpdateableKey<Category>] {
        return []
    }
}
