import Vapor
import FluentProvider
import HTTP

final class Post: Model {
    
    let storage = Storage()

    var title: String
    var content: String
    var isPublish: Bool
    var categoryId: Identifier?
    var userId: Identifier?
    
    static let idKey = "id"
    static let titleKey = "title"
    static let contentKey = "content"
    static let isPublishKey = "is_publish"

    init(title: String, content: String, isPublish: Bool, category: Category, user: User) {
        self.title = title
        self.content = content
        self.isPublish = isPublish
        self.categoryId = category.id
        self.userId = user.id
    }

    init(row: Row) throws {
        title = try row.get(Post.titleKey)
        content = try row.get(Post.contentKey)
        isPublish = try row.get(Post.isPublishKey)
        categoryId = try row.get(Category.foreignIdKey)
        userId = try row.get(User.foreignIdKey)
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Post.titleKey, title)
        try row.set(Post.contentKey, content)
        try row.set(Post.isPublishKey, isPublish)
        try row.set(Category.foreignIdKey, categoryId)
        try row.set(User.foreignIdKey, userId)
        return row
    }
}

// MARK: - Preparation
extension Post: Preparation {
    
    static func prepare(_ database: Database) throws {
        
        try database.create(self) { builder in
            builder.id()
            builder.string(Post.titleKey)
            builder.string(Post.contentKey)
            builder.bool(Post.isPublishKey)
            builder.parent(Category.self)
            builder.parent(User.self)
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: - JSONRepresentable
extension Post: JSONRepresentable {
    
    func makeJSON() throws -> JSON {
        var row = try makeRow()
        try row.set(Post.idKey, id)
        return JSON(row)
    }
}

// MARK: - ResponseRepresentable
extension Post: ResponseRepresentable {}

// MARK: - Relation
extension Post {
    
    var category: Parent<Post, Category> {
        return parent(id: categoryId)
    }
    
    var user: Parent<Post, User> {
        return parent(id: userId)
    }
    
    var tags: Siblings<Post, Tag, Pivot<Post, Tag>> {
        return siblings()
    }
}
