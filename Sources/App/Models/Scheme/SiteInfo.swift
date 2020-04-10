import Fluent
import Vapor

final class SiteInfo: Model {

    static let schema = "siteinfos"

    @ID(custom: .id)
    var id: Int?

    @Field(key: "name")
    var name: String

    @Field(key: "description")
    var description: String

    @Field(key: "theme")
    var theme: String?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    var selectedTheme: String {
        return theme ?? SiteInfo.defaultTheme
    }

    init() {}

    init(name: String, description: String) {
        self.name = name
        self.description = description
    }
}

extension SiteInfo {
    static let nameLength = 32
    static let descriptionLength = 128
    static let defaultTheme = "default"
}

extension SiteInfo {
    func apply(form: SiteInfoForm) {
        name = form.name
        description = form.description
    }
}

extension SiteInfo {
    static func shared(on db: Database) -> EventLoopFuture<SiteInfo> {
        return SiteInfo.find(1, on: db).unwrap(or: Abort(.internalServerError))
    }
}

struct CreateSiteInfo: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(SiteInfo.schema)
            .field(.id, .int64, .identifier(auto: true))
            .field("name", .string, .required)
            .field("description", .string, .required)
            .field("theme", .string)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .ignoreExisting()
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(SiteInfo.schema).delete()
    }
}
