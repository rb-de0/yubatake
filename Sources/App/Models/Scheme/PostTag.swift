import Fluent
import Vapor

final class PostTag: Model {

    static let schema = "post_tag"

    @ID(custom: .id)
    var id: Int?

    @Parent(key: "post_id")
    var post: Post

    @Parent(key: "tag_id")
    var tag: Tag
}

struct CreatePostTag: Migration {

    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PostTag.schema)
            .field(.id, .int64, .identifier(auto: true))
            .field("post_id", .int64, .required, .references(Post.schema, "id", onDelete: .cascade, onUpdate: .restrict))
            .field("tag_id", .int64, .required, .references(Tag.schema, "id", onDelete: .cascade, onUpdate: .restrict))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .ignoreExisting()
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("images").delete()
    }
}
