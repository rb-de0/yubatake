import FluentProvider

struct TwitterAuth: Preparation {
    
    static func prepare(_ database: Database) throws {
        
        try database.modify(User.self) { modifier in
            modifier.string(User.apiKeyKey)
            modifier.string(User.apiSecretKey)
            modifier.string(User.accessTokenKey)
            modifier.string(User.accessTokenSecretKey)
        }
    }
    
    static func revert(_ database: Database) throws {
        
        try database.modify(User.self) { modifier in
            modifier.delete(User.apiKeyKey)
            modifier.delete(User.apiSecretKey)
            modifier.delete(User.accessTokenKey)
            modifier.delete(User.accessTokenSecretKey)
        }
    }
}

