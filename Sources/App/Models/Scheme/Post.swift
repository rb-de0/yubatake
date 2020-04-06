import Fluent
import SwiftSoup
import Vapor

final class Post: Model {

    static let schema = "posts"

    @ID(custom: .id)
    var id: Int?

    @Field(key: "title")
    var title: String

    @Field(key: "content")
    var content: String

    @Field(key: "html_content")
    var htmlContent: String

    @Field(key: "part_of_content")
    var partOfContent: String

    @OptionalParent(key: "category_id")
    var category: Category?

    @OptionalParent(key: "user_id")
    var user: User?

    @Field(key: "is_static")
    var isStatic: Bool

    @Field(key: "is_published")
    var isPublished: Bool

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Siblings(through: PostTag.self, from: \.$post, to: \.$tag)
    var tags: [Tag]

    init() {}

    init(from form: PostForm, userId: Int) throws {
        title = form.title
        content = form.content
        htmlContent = content.htmlFromMarkdown ?? ""
        partOfContent = try SwiftSoup.parse(htmlContent).text().take(n: Post.partOfContentLength)
        isStatic = form.isStatic
        isPublished = form.isPublished
        $category.id = form.category
        $user.id = userId
    }
}

extension Post {
    func apply(form: PostForm, userId: Int) throws {
        title = form.title
        content = form.content
        htmlContent = content.htmlFromMarkdown ?? ""
        partOfContent = try SwiftSoup.parse(htmlContent).text().take(n: Post.partOfContentLength)
        isStatic = form.isStatic
        isPublished = form.isPublished
        $category.id = form.category
        $user.id = userId
    }
}

extension Post {
    static func recentPosts(on db: Database, count: Int = Post.recentPostCount) -> EventLoopFuture<[Post]> {
        return Post.query(on: db).publicAll().noStaticAll().withRelated()
            .sort(\.$createdAt)
            .range(lower: 0, upper: count)
            .all()
    }

    static func staticContents(on db: Database) -> EventLoopFuture<[Post]> {
        return Post.query(on: db).publicAll().staticAll().all()
    }
}

extension Post {
    static let recentPostCount = 10
    static let titleLength = 128
    static let contentLength = 8192
    static let partOfContentLength = 150
}

extension Post {
    struct Public: ResponseContent {
        private enum CodingKeys: String, CodingKey {
            case user
            case category
            case tags
            case tagsString
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
            tagsString = tags.map { $0.name }.joined(separator: Tag.separator)
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

    func formPublic() throws -> Public {
        return Public(
            post: self,
            user: try user?.formPublic(),
            category: category,
            tags: tags
        )
    }
}

extension QueryBuilder where Model == Post {
    func publicAll() -> Self {
        return filter(\.$isPublished == .sql(raw: "1"))
    }

    func noStaticAll() -> Self {
        return filter(\.$isStatic == .sql(raw: "0"))
    }

    func staticAll() -> Self {
        return filter(\.$isStatic == .sql(raw: "1"))
    }

    func noCategoryAll() -> Self {
        return filter(\.$category.$id == nil)
    }

    func withRelated() -> Self {
        return with(\.$user).with(\.$category).with(\.$tags)
    }
}

struct CreatePost: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Post.schema)
            .field(.id, .int64, .identifier(auto: true))
            .field("title", .custom("varchar(\(Post.titleLength))"), .required)
            .field("content", .custom("varchar(\(Post.contentLength))"), .required)
            .field("html_content", .string, .required)
            .field("part_of_content", .custom("varchar(\(Post.partOfContentLength))"), .required)
            .field("category_id", .int64, .references(Category.schema, "id"))
            .field("user_id", .int64, .references(User.schema, "id"))
            .field("is_static", .bool, .required)
            .field("is_published", .bool, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .ignoreExisting()
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Post.schema).delete()
    }
}
