import Vapor
import FluentProvider
import HTTP

final class Post: Model {
    
    static let idKey = "id"
    static let titleKey = "title"
    static let contentKey = "content"
    static let isPublishKey = "is_publish"
    static let categoryKey = "category"
    static let userKey = "user"
    static let tagsKey = "tags"
    static let tagsStringKey = "tagsString"
    static let createdAtKey = "createdAt"
    static let updatedAtKey = "updatedAt"
    
    let storage = Storage()

    var title: String
    var content: String
    var isPublish: Bool
    var categoryId: Identifier?
    var userId: Identifier?
    
    init(request: Request) {
        title = request.data[Post.titleKey]?.string ?? ""
        content = request.data[Post.contentKey]?.string ?? ""
        isPublish = request.data[Post.isPublishKey]?.bool ?? false
        categoryId = request.data[Post.categoryKey]?.int.map { Identifier($0) }
        
        // TODO: User from auth
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
            builder.parent(Category.self, optional: true)
            builder.parent(User.self, optional: true)
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
        let relatedTags = try tags.all()
        try row.set(Post.idKey, id)
        try row.set(Post.categoryKey, category.get()?.makeJSON())
        try row.set(Post.userKey, user.get()?.makeJSON())
        try row.set(Post.tagsKey, relatedTags.makeJSON())
        try row.set(Post.tagsStringKey, relatedTags.map { $0.name }.joined(separator: Tag.separator))
        try row.set(Post.createdAtKey, createdAt)
        try row.set(Post.updatedAtKey, updatedAt)
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

// MARK: - Timestampable
extension Post: Timestampable {}

// MARK: - Paginatable
extension Post: Paginatable {}


// MARK: - Updateable
extension Post: Updateable {
    
    func update(for req: Request) throws {
        title = req.data[Post.titleKey]?.string ?? ""
        content = req.data[Post.contentKey]?.string ?? ""
        isPublish = req.data[Post.isPublishKey]?.bool ?? false
        categoryId = req.data[Post.categoryKey]?.int.map { Identifier($0) }
    }
    
    static var updateableKeys: [UpdateableKey<Post>] {
        return []
    }
}
