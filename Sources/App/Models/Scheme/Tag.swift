import Fluent
import Vapor

final class Tag: Model {

    static let schema = "tags"

    @ID(custom: .id)
    var id: Int?

    @Field(key: "name")
    var name: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Siblings(through: PostTag.self, from: \.$tag, to: \.$post)
    var posts: [Post]

    init() {}

    init(name: String) {
        self.name = name
    }

    init(form: TagForm) {
        name = form.name
    }
}

extension Tag {
    static let nameLength = 16
}

extension Tag {
    func apply(form: TagForm) {
        name = form.name
    }
}

extension Tag {
    static func tags(from form: PostForm) -> [Tag] {
        let tagStrings = form.tags.components(separatedBy: Tag.separator)
        return tagStrings.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.map { Tag(name: $0) }
    }

    static func notInsertedTags(in tags: [Tag], on db: Database) -> EventLoopFuture<[Tag]> {
        return tags
            .map { tag in Tag.query(on: db).filter(\.$name == tag.name).count().map { count in (count, tag) } }
            .flatten(on: db.eventLoop)
            .map { tags in tags.filter { $0.0 == 0 }.map { $0.1 } }
    }

    static func insertedTags(in tags: [Tag], on db: Database) -> EventLoopFuture<[Tag]> {
        return tags
            .map { Tag.query(on: db).filter(\.$name == $0.name).first() }
            .flatten(on: db.eventLoop)
            .map { tags in tags.compactMap { $0 } }
    }
}

extension Tag {
    struct NumberOfPosts: Content {
        let tag: Tag
        let count: Int
    }
}

extension Tag {
    static func numberOfPosts(on db: Database, count: Int = 10) -> EventLoopFuture<[NumberOfPosts]> {
        return Tag.query(on: db).withRelated()
            .all()
            .flatMap { tags in
                let counts = tags.map { tag in
                    tag.$posts.query(on: db).publicAll().noStaticAll().withRelated()
                        .count()
                        .map { NumberOfPosts(tag: tag, count: $0) }
                }
                return counts.flatten(on: db.eventLoop)
                    .map { $0.filter { $0.count > 0 }.sorted(by: { $0.count > $1.count }).take(n: count) }
            }
    }
}

extension QueryBuilder where Model == Tag {
    func withRelated() -> Self {
        return with(\.$posts)
    }
}

extension Tag {
    static let separator = ","
}

struct CreateTag: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Tag.schema)
            .field(.id, .int64, .identifier(auto: true))
            .field("name", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "name")
            .ignoreExisting()
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Tag.schema).delete()
    }
}
