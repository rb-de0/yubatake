import AuthProvider
import Crypto
import FluentProvider
import HTTP
import ValidationProvider
import Vapor
import Poppo

final class User: Model {
    
    static let idKey = "id"
    static let nameKey = "name"
    static let passwordKey = "password"
    static let apiKeyKey = "api_key"
    static let apiSecretKey = "api_secret"
    static let accessTokenKey = "access_token"
    static let accessTokenSecretKey = "access_token_secret"
    
    let storage = Storage()
    
    var name: String
    var password: String
    var apiKey = ""
    var apiSecret = ""
    var accessToken = ""
    var accessTokenSecret = ""
    
    init(name: String, password: String) {
        self.name = name
        self.password = password
    }
    
    init(row: Row) throws {
        name = try row.get(User.nameKey)
        password = try row.get(User.passwordKey)
        apiKey = try row.get(User.apiKeyKey)
        apiSecret = try row.get(User.apiSecretKey)
        accessToken = try row.get(User.accessTokenKey)
        accessTokenSecret = try row.get(User.accessTokenSecretKey)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(User.nameKey, name)
        try row.set(User.passwordKey, password)
        try row.set(User.apiKeyKey, apiKey)
        try row.set(User.apiSecretKey, apiSecret)
        try row.set(User.accessTokenKey, accessToken)
        try row.set(User.accessTokenSecretKey, accessTokenSecret)
        return row
    }
    
    func makePoppo() -> Poppo {
        
        return Poppo(
            consumerKey: apiKey,
            consumerKeySecret: apiSecret,
            accessToken: accessToken,
            accessTokenSecret: accessTokenSecret
        )
    }
}

// MARK: - Preparation
extension User: Preparation {
    
    static func prepare(_ database: Database) throws {
        
        try database.create(self) { builder in
            builder.id()
            builder.string(User.nameKey)
            builder.string(User.passwordKey)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: - JSONRepresentable
extension User: JSONRepresentable {
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(User.idKey, id)
        try json.set(User.nameKey, name)
        try json.set(User.apiKeyKey, apiKey)
        try json.set(User.apiSecretKey, apiSecret)
        try json.set(User.accessTokenKey, accessToken)
        try json.set(User.accessTokenSecretKey, accessTokenSecret)
        return json
    }
}

// MARK: - ResponseRepresentable
extension User: ResponseRepresentable {}

// MARK: - Relation
extension User {
    
    var posts: Children<User, Post> {
        return children()
    }
}

// MARK: - Updateable
extension User: Updateable {
    
    func update(for req: Request) throws {
        
        let rawPassword = req.data[User.passwordKey]?.string ?? ""
        
        name = req.data[User.nameKey]?.string ?? ""
        password = try HashHelper.hash.make(rawPassword).makeString()
        apiKey = req.data[User.apiKeyKey]?.string ?? ""
        apiSecret = req.data[User.apiSecretKey]?.string ?? ""
        accessToken = req.data[User.accessTokenKey]?.string ?? ""
        accessTokenSecret = req.data[User.accessTokenSecretKey]?.string ?? ""
        
        try name.validated(by: Count.containedIn(low: 1, high: 32))
        try rawPassword.validated(by: Count.containedIn(low: 1, high: 32))
    }
    
    static var updateableKeys: [UpdateableKey<User>] {
        return []
    }
}

// MARK: - PasswordAuthenticatable
extension User: PasswordAuthenticatable {

    static var usernameKey: String {
        return User.nameKey
    }
}

// MARK: - SessionPersistable
extension User: SessionPersistable {}

extension User {
    
    static func makeRootUser() throws -> (user: User, rawPassword: String) {
        let rawPassword = try Crypto.Random.bytes(count: 16).base64Encoded.makeString()
        let password = try HashHelper.hash.make(rawPassword).makeString()
        return (User(name: "root", password: password), rawPassword)
    }
}

extension Request {
    
    func userNamePassword() throws -> Password {
        
        guard let userName = data[User.usernameKey]?.string,
            let password = data[User.passwordKey]?.string else {
            
            throw Abort(.badRequest)
        }
        
        let hassedPassword = try HashHelper.hash.make(password).makeString()
        return Password(username: userName, password: hassedPassword)
    }
}
