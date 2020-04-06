import Fluent
import Vapor

final class Image: Model {

    static let schema = "images"

    @ID(custom: .id)
    var id: Int?

    @Field(key: "path")
    var path: String

    @Field(key: "alt_description")
    var altDescription: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() {}

    init(from name: String, on application: Application) throws {
        let relativePath = application.fileConfig.imageRoot
        path = relativePath.started(with: "/").finished(with: "/").appending(name)
        altDescription = name
    }
}

extension Image {
    func apply(form: ImageForm, on application: Application) {
        let relativePath = application.fileConfig.imageRoot
        path = relativePath.started(with: "/").finished(with: "/").appending(form.name)
        altDescription = form.altDescription
    }
}

extension Image {
    func formPublic(on application: Application) -> Public {
        let relativePath = application.fileConfig.imageRoot
        let basePath = relativePath.started(with: "/").finished(with: "/")
        return Public(image: self, name: String(path.dropFirst(basePath.count)))
    }
}

extension Image {
    struct Public: ResponseContent {
        private enum CodingKeys: String, CodingKey {
            case name
        }

        let image: Image
        let name: String

        func encode(to encoder: Encoder) throws {
            try image.encode(to: encoder)
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
        }
    }
}

struct CreateImage: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Image.schema)
            .field(.id, .int64, .identifier(auto: true))
            .field("path", .string, .required)
            .field("alt_description", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "path")
            .ignoreExisting()
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Image.schema).delete()
    }
}
