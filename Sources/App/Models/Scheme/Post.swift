import FluentMySQL
import Pagination
import SwiftSoup
import Vapor

final class Post: DatabaseModel {
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case htmlContent = "html_content"
        case partOfContent = "part_of_content"
        case categoryId = "category_id"
        case userId = "user_id"
        case isStatic = "is_static"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    struct Public: PageResponse {
        
        private enum CodingKeys: String, CodingKey {
            case user
            case category
            case tags
            case tagsString = "tags_string"
            case formattedCreatedAt = "formatted_created_at"
            case formattedUpdatedAt = "formatted_updated_at"
        }
        
        let post: Post
        let user: User.Public?
        let category: Category?
        let tags: [Tag]
        let tagsString: String
        let formattedCreatedAt: String?
        let formattedUpdatedAt: String?
        
        init(post: Post, user: User.Public?, category: Category?, tags: [Tag], dateFormat: String) {
            self.post = post
            self.user = user
            self.category = category
            self.tags = tags
            self.tagsString = tags.map { $0.name }.joined(separator: Tag.separator)
            self.formattedCreatedAt = post.formattedCreatedAt(dateFormat: dateFormat)
            self.formattedUpdatedAt = post.formattedUpdatedAt(dateFormat: dateFormat)
        }

        func encode(to encoder: Encoder) throws {
            try post.encode(to: encoder)
            var container = encoder.container(keyedBy: Public.CodingKeys.self)
            try container.encodeIfPresent(user, forKey: .user)
            try container.encodeIfPresent(category, forKey: .category)
            try container.encode(tags, forKey: .tags)
            try container.encode(tagsString, forKey: .tagsString)
            try container.encodeIfPresent(formattedCreatedAt, forKey: .formattedCreatedAt)
            try container.encodeIfPresent(formattedUpdatedAt, forKey: .formattedUpdatedAt)
        }
    }
    
    static let recentPostCount = 10
    static let titleLength = 128
    static let contentLength = 8192
    static let partOfContentLength = 150

    var id: Int?
    var title: String
    var content: String
    var htmlContent: String
    var partOfContent: String
    var categoryId: Int?
    var userId: Int?
    var isStatic: Bool
    var createdAt: Date?
    var updatedAt: Date?
    
    init(from form: PostForm, on request: Request) throws {
        
        title = form.title
        content = form.content
        htmlContent = content.htmlFromMarkdown ?? ""
        partOfContent = try SwiftSoup.parse(htmlContent).text().take(n: Post.partOfContentLength)
        isStatic = form.isStatic
        
        categoryId = form.category
        userId = try request.requireAuthenticated(User.self).id
        
        try validate()
    }
    
    func apply(form: PostForm, on request: Request) throws -> Post {
        
        title = form.title
        content = form.content
        htmlContent = content.htmlFromMarkdown ?? ""
        partOfContent = try SwiftSoup.parse(htmlContent).text().take(n: Post.partOfContentLength)
        isStatic = form.isStatic
        
        categoryId = form.category
        userId = try request.requireAuthenticated(User.self).id
        
        try validate()
        
        return self
    }
    
    func formPublic(on request: Request) throws -> Future<Public> {
        
        let dateFormat = try request.make(ApplicationConfig.self).dateFormat
        let _user = try user?.get(on: request)
        let _category = try category?.get(on: request)
        let _tags = try tags.query(on: request).all()
        
        return _user.form(on: request.eventLoop)
            .map { try $0?.formPublic() }
            .and(_category.form(on: request.eventLoop))
            .and(_tags)
            .map { ($0.0.0, $0.0.1, $0.1) }
            .map { (user, category, tags) in
                return Public(post: self, user: user, category: category, tags: tags, dateFormat: dateFormat)
            }
    }
    
    // MARK: - Static
    
    static func recentPosts(on conn: DatabaseConnectable, count: Int = Post.recentPostCount) throws -> Future<[Post]> {
        return try Post.query(on: conn).publicAll()
            .sort(\Post.createdAt, .descending)
            .range(lower: 0, upper: count)
            .all()
    }
    
    static func staticContents(on conn: DatabaseConnectable) throws -> Future<[Post]> {
        return try Post.query(on: conn).staticAll().all()
    }
}

// MARK: - Relation
extension Post {
    
    var category: Parent<Post, Category>? {
        return parent(\.categoryId)
    }
    
    var user: Parent<Post, User>? {
        return parent(\.userId)
    }
    
    var tags: Siblings<Post, Tag, PostTag> {
        return siblings()
    }
}

// MARK: - Paginatable
extension Post: Paginatable {}

// MARK: - Validatable
extension Post: Validatable {
    
    static func validations() throws -> Validations<Post> {
        var validations = Validations(Post.self)
        try validations.add(\.title, .count(1...Post.titleLength))
        try validations.add(\.content, .count(1...Post.contentLength))
        return validations
    }
}

extension QueryBuilder where Model == Post {
    
    func publicAll() throws -> Self {
        return try filter(\Post.isStatic == false)
    }
    
    func staticAll() throws -> Self {
        return try filter(\Post.isStatic == true)
    }
    
    func noCategoryAll() throws -> Self {
        return try filter(\Post.categoryId == nil)
    }
}
