import Fluent
import Vapor

final class Category: Model {

    static let schema = "categories"

    @ID(custom: .id)
    var id: Int?

    @Field(key: "name")
    var name: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Children(for: \.$category)
    var posts: [Post]

    init() {}

    init(form: CategoryForm) {
        name = form.name
    }
}

extension Category {
    static let nameLength = 32
}

extension Category {
    func apply(form: CategoryForm) {
        name = form.name
    }
}

extension Category {
    struct NumberOfPosts: Content {
        let category: Category
        let count: Int
    }
}

extension QueryBuilder where Model == Category {
    func withRelated() -> Self {
        return with(\.$posts)
    }
}

extension Category {
    static func numberOfPosts(on db: Database, count: Int = 10) -> EventLoopFuture<[NumberOfPosts]> {
        return Category.query(on: db).withRelated()
            .all()
            .flatMap { categories in
                let counts = categories.map { category in
                    category.$posts.query(on: db).publicAll().noStaticAll().withRelated()
                        .count()
                        .map { NumberOfPosts(category: category, count: $0) }
                }
                return counts.flatten(on: db.eventLoop)
                    .map { $0.filter { $0.count > 0 }.sorted(by: { $0.count > $1.count }).take(n: count) }
            }
    }
}

struct CreateCategory: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Category.schema)
            .field(.id, .int64, .identifier(auto: true))
            .field("name", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "name")
            .ignoreExisting()
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Category.schema).delete()
    }
}
