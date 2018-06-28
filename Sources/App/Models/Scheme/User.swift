import Authentication
import Crypto
import FluentMySQL
import Foundation
import Poppo
import Vapor

final class User: DatabaseModel {
    
    static let entity = "users"
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case password
        case apiKey = "api_key"
        case apiSecret = "api_secret"
        case accessToken = "access_token"
        case accessTokenSecret = "access_token_secret"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    struct Public: ResponseContent {
        
        private enum CodingKeys: String, CodingKey {
            case id
            case name
            case apiKey = "api_key"
            case apiSecret = "api_secret"
            case accessToken = "access_token"
            case accessTokenSecret = "access_token_secret"
        }
        
        let id: Int
        let name: String
        let apiKey: String
        let apiSecret: String
        let accessToken: String
        let accessTokenSecret: String
    }
    
    static let nameLength = 32
    
    var id: Int?
    var name: String
    var password: String
    var apiKey = ""
    var apiSecret = ""
    var accessToken = ""
    var accessTokenSecret = ""
    var createdAt: Date?
    var updatedAt: Date?
    
    init(name: String, password: String) {
        self.name = name
        self.password = password
    }
    
    func apply(form: UserForm, on container: Container) throws -> Future<User>  {
        
        let promise = container.eventLoop.newPromise(User.self)
        let bcrypt = try container.make(BCryptDigest.self)
        
        DispatchQueue.global().async {
            
            do {
                let password = try bcrypt.hash(form.password)
                self.name = form.name
                self.password = password
                self.apiKey = form.apiKey ?? ""
                self.apiSecret = form.apiSecret ?? ""
                self.accessToken = form.accessToken ?? ""
                self.accessTokenSecret = form.accessTokenSecret ?? ""
                
                try self.validate()
                
                promise.succeed(result: self)
            } catch {
                promise.fail(error: error)
            }
        }
        
        return promise.futureResult
    }
    
    func formPublic() throws -> Public {
        return Public(id: try requireID(), name: name, apiKey: apiKey, apiSecret: apiSecret, accessToken: accessToken, accessTokenSecret: accessTokenSecret)
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

extension User {
    
    static func makeRootUser(using container: Container) throws -> (user: User, rawPassword: String) {
        let rawPassword = try CryptoRandom().generateData(count: 16).base64EncodedString()
        let password = try container.make(BCryptDigest.self).hash(rawPassword)
        return (User(name: "root", password: password), rawPassword)
    }
}

extension User {
    
    var posts: Children<User, Post> {
        return children(\Post.userId)
    }
}

// MARK: - Validatable
extension User: Validatable {
    
    static func validations() throws -> Validations<User> {
        var validations = Validations(User.self)
        try validations.add(\.name, .count(1...User.nameLength))
        return validations
    }
}

// MARK: - SessionAuthenticatable
extension User: SessionAuthenticatable {}

// MARK: - PasswordAuthenticatable
extension User: PasswordAuthenticatable {
    
    static var usernameKey: WritableKeyPath<User, String> {
        return \.name
    }
    
    static var passwordKey: WritableKeyPath<User, String> {
        return \.password
    }
}
