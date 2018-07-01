import FluentMySQL

extension User: Migration {}

extension Category: Migration {
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.name)
        }
    }
}

extension Tag: Migration {
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.name)
        }
    }
}

extension Post: Migration {
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        
        return Database.create(self, on: connection) { builder in
            builder.field(for: idKey)
            builder.field(for: \.title, type: .varchar(Post.titleLength))
            builder.field(for: \.content, type: .varchar(Post.contentLength))
            builder.field(for: \.htmlContent, type: .varchar(Post.contentLength))
            builder.field(for: \.partOfContent, type: .varchar(Post.partOfContentLength))
            builder.field(for: \.categoryId)
            builder.field(for: \.userId)
            builder.field(for: \.isStatic, type: .bool)
            builder.field(for: \.isPublished, type: .bool)
            builder.field(for: \.createdAt)
            builder.field(for: \.updatedAt)
            builder.reference(from: \.categoryId, to: \Category.id)
            builder.reference(from: \.userId, to: \User.id)
        }
    }
}

extension PostTag: Migration {
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        
        return Database.create(self, on: connection) { builder in
            builder.field(for: idKey)
            builder.field(for: leftIDKey)
            builder.field(for: rightIDKey)
            builder.reference(from: leftIDKey, to: \Post.id, onUpdate: .restrict, onDelete: .cascade)
            builder.reference(from: rightIDKey, to: \Tag.id, onUpdate: .restrict, onDelete: .cascade)
        }
    }
}

extension SiteInfo: Migration {}

extension Image: Migration {
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.path)
        }
    }
}

