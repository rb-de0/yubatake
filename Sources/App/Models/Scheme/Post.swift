import FluentMySQL
import Pagination
import SwiftSoup
import Vapor

final class Post: DatabaseModel {
    
    static let entity = "posts"
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case htmlContent = "html_content"
        case partOfContent = "part_of_content"
        case categoryId = "category_id"
        case userId = "user_id"
        case isStatic = "is_static"
        case isPublished = "is_published"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    struct Public: PageResponse {
        
        private enum CodingKeys: String, CodingKey {
            case user
            case category
            case tags
            case tagsString = "tags_string"
        }
        
        let post: Post
        let user: User.Public?
        let category: Category?
        let tags: [Tag]
        let tagsString: String
        
        init(post: Post, user: User.Public?, category: Category?, tags: [Tag]) {
            self.post = post
            self.user = user
            self.category = category
            self.tags = tags
            self.tagsString = tags.map { $0.name }.joined(separator: Tag.separator)
        }

        func encode(to encoder: Encoder) throws {
            try post.encode(to: encoder)
            var container = encoder.container(keyedBy: Public.CodingKeys.self)
            try container.encodeIfPresent(user, forKey: .user)
            try container.encodeIfPresent(category, forKey: .category)
            try container.encode(tags, forKey: .tags)
            try container.encode(tagsString, forKey: .tagsString)
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
    var isPublished: Bool
    var createdAt: Date?
    var updatedAt: Date?
    
    init(from form: PostForm, on request: Request) throws {
        
        title = form.title
        content = form.content
        htmlContent = content.htmlFromMarkdown ?? ""
        partOfContent = try SwiftSoup.parse(htmlContent).text().take(n: Post.partOfContentLength)
        isStatic = form.isStatic
        isPublished = form.isPublished
        
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
        isPublished = form.isPublished
        
        categoryId = form.category
        userId = try request.requireAuthenticated(User.self).id
        
        try validate()
        
        return self
    }
    
    func formPublic(on request: Request) throws -> Future<Public> {
        
        let _user = user?.get(on: request)
        let _category = category?.get(on: request)
        let _tags = try tags.query(on: request).all()
        
        return _user.form(on: request.eventLoop)
            .map { try $0?.formPublic() }
            .and(_category.form(on: request.eventLoop))
            .and(_tags)
            .map { ($0.0.0, $0.0.1, $0.1) }
            .map { (user, category, tags) in
                return Public(post: self, user: user, category: category, tags: tags)
            }
    }
    
    // MARK: - Static
    
    static func recentPosts(on conn: DatabaseConnectable, count: Int = Post.recentPostCount) throws -> Future<[Post]> {
        return try Post.query(on: conn).noStaticAll().publicAll()
            .sort(\Post.createdAt, .descending)
            .range(lower: 0, upper: count)
            .all()
    }
    
    static func staticContents(on conn: DatabaseConnectable) throws -> Future<[Post]> {
        return try Post.query(on: conn).staticAll().publicAll().all()
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

extension QueryBuilder where Result == Post {
    
    func publicAll() throws -> Self {
        return filter(\Post.isPublished == true)
    }
    
    func noStaticAll() throws -> Self {
        return filter(\Post.isStatic == false)
    }
    
    func staticAll() throws -> Self {
        return filter(\Post.isStatic == true)
    }
    
    func noCategoryAll() throws -> Self {
        return filter(\Post.categoryId == nil)
    }
}
