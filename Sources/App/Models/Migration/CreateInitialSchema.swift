import FluentMySQL

extension User: Migration {}

extension Category: Migration {
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            try builder.addIndex(to: \.name, isUnique: true)
        }
    }
}

extension Tag: Migration {
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            try builder.addIndex(to: \.name, isUnique: true)
        }
    }
}

extension Post: Migration {
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        
        return Database.create(self, on: connection) { builder in
            try builder.field(for: idKey)
            try builder.field(type: .varChar(length: Post.titleLength), for: \.title)
            try builder.field(type: .varChar(length: Post.contentLength), for: \.content)
            try builder.field(type: .varChar(length: Post.contentLength), for: \.htmlContent)
            try builder.field(type: .varChar(length: Post.partOfContentLength), for: \.partOfContent)
            try builder.field(for: \.categoryId, referencing: \Category.id)
            try builder.field(for: \.userId, referencing: \User.id)
            try builder.field(type: .bool(), for: \.isStatic)
            try builder.field(for: \.createdAt)
            try builder.field(for: \.updatedAt)
        }
    }
}

extension PostTag: Migration {
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        
        return Database.create(self, on: connection) { builder in
            try builder.field(for: idKey)
            try builder.field(for: leftIDKey, referencing: \Post.id, actions: .update)
            try builder.field(for: rightIDKey, referencing: \Tag.id)
        }
    }
}

extension SiteInfo: Migration {}
extension Image: Migration {}

