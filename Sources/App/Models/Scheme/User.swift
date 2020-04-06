import Cryptor
import Fluent
import Poppo
import Vapor

final class User: Model {

    static let schema = "users"

    @ID(custom: .id)
    var id: Int?

    @Field(key: "name")
    var name: String

    @Field(key: "password")
    var password: String

    @Field(key: "api_key")
    var apiKey: String

    @Field(key: "api_secret")
    var apiSecret: String

    @Field(key: "access_token")
    var accessToken: String

    @Field(key: "access_token_secret")
    var accessTokenSecret: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Children(for: \.$user)
    var posts: [Post]

    init() {}

    init(name: String, password: String) {
        self.name = name
        self.password = password
        apiKey = ""
        apiSecret = ""
        accessToken = ""
        accessTokenSecret = ""
    }
}

extension User {
    static let nameLength = 32
}

extension User {
    func apply(form: UserForm, on request: Request) -> EventLoopFuture<Void> {
        let promise = request.eventLoop.makePromise(of: Void.self)
        DispatchQueue.global().async {
            do {
                self.name = form.name
                self.password = try Bcrypt.hash(form.password)
                self.apiKey = form.apiKey ?? ""
                self.apiSecret = form.apiSecret ?? ""
                self.accessToken = form.accessToken ?? ""
                self.accessTokenSecret = form.accessTokenSecret ?? ""
                promise.succeed(())
            } catch {
                promise.fail(error)
            }
        }
        return promise.futureResult
    }
}

extension QueryBuilder where Model == User {
    func withRelated() -> Self {
        return with(\.$posts)
    }
}

extension User {
    struct Public: ResponseContent {
        private enum CodingKeys: String, CodingKey {
            case id
            case name
            case apiKey
            case apiSecret
            case accessToken
            case accessTokenSecret
        }

        let id: Int
        let name: String
        let apiKey: String
        let apiSecret: String
        let accessToken: String
        let accessTokenSecret: String
    }
}

extension User {
    func formPublic() throws -> Public {
        return Public(
            id: try requireID(),
            name: name,
            apiKey: apiKey,
            apiSecret: apiSecret,
            accessToken: accessToken,
            accessTokenSecret: accessTokenSecret
        )
    }
}

extension User: SessionAuthenticatable {
    var sessionID: Int? { id }
}

extension User {
    class func authenticate(username: String, password: String, verifier: PasswordVerifier, on request: Request) -> EventLoopFuture<User> {
        User.query(on: request.db).filter(\.$name == username).first()
            .unwrap(or: Abort(.unauthorized))
            .flatMapThrowing { user -> User in
                guard let inputPasswordData = password.data(using: .utf8),
                    let passwordData = user.password.data(using: .utf8) else {
                    throw Abort(.unauthorized)
                }
                let isOk = try verifier.verify(inputPasswordData, created: passwordData)
                if isOk {
                    return user
                } else {
                    throw Abort(.unauthorized)
                }
            }
    }
}

extension User {
    class func makeRootUser(using _: Application) throws -> (user: User, rawPassword: String) {
        let rawPassword = try Random.generate(byteCount: 16).base64
        let password = try Bcrypt.hash(rawPassword)
        return (User(name: "root", password: password), rawPassword)
    }
}

extension User {
    func makePoppo() -> Poppo {
        return Poppo(
            consumerKey: apiKey,
            consumerKeySecret: apiSecret,
            accessToken: accessToken,
            accessTokenSecret: accessTokenSecret
        )
    }
}

struct CreateUser: Migration {

    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema)
            .field(.id, .int64, .identifier(auto: true))
            .field("name", .string, .required)
            .field("password", .string, .required)
            .field("api_key", .string, .required)
            .field("api_secret", .string, .required)
            .field("access_token", .string, .required)
            .field("access_token_secret", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .ignoreExisting()
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema).delete()
    }
}
