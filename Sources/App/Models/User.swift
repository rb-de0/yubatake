import AuthProvider
import Crypto
import FluentProvider
import HTTP
import Vapor

final class User: Model {
    
    static let idKey = "id"
    static let nameKey = "name"
    static let passwordKey = "password"
    
    let storage = Storage()
    
    var name: String
    var password: String
    
    init(name: String, password: String) {
        self.name = name
        self.password = password
    }
    
    init(row: Row) throws {
        name = try row.get(User.nameKey)
        password = try row.get(User.passwordKey)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(User.nameKey, name)
        try row.set(User.passwordKey, password)
        return row
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
