import FluentProvider

struct SupportStaticContent: Preparation {
    
    static func prepare(_ database: Database) throws {
        
        try database.modify(Post.self) { modifier in
            modifier.bool(Post.isStaticKey, default: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        
        try database.modify(Post.self) { modifier in
            modifier.delete(Post.isStaticKey)
        }
    }
}
