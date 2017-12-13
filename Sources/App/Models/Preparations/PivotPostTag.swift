import FluentProvider

struct PivotPostTag: Preparation {
    
    static func prepare(_ database: Database) throws {
        
        let tmpQuery = try Post.makeQuery()
        let postForeignKey = ForeignKey(entity: Pivot<Post, Tag>.self, field: Post.foreignIdKey, foreignField: Post.idKey, foreignEntity: Post.self)
        let tagForeignKey = ForeignKey(entity: Pivot<Post, Tag>.self, field: Tag.foreignIdKey, foreignField: Tag.idKey, foreignEntity: Tag.self)
        
        try database.raw("alter table \(Pivot<Post, Tag>.name) drop foreign key `\(postForeignKey.name)`")
        try database.raw("alter table \(Pivot<Post, Tag>.name) drop foreign key `\(tagForeignKey.name)`")
        try database.raw("alter table \(Pivot<Post, Tag>.name) drop index `\(tagForeignKey.name)`")
        try database.raw("alter table \(Pivot<Post, Tag>.name) drop index `\(postForeignKey.name)`")
        
        let postAddKeySQL = GeneralSQLSerializer(tmpQuery).foreignKey(RawOr.some(postForeignKey))
        try database.raw("alter table \(Pivot<Post, Tag>.name) add \(postAddKeySQL) on delete cascade")
        
        let tagAddKeySQL = GeneralSQLSerializer(tmpQuery).foreignKey(RawOr.some(tagForeignKey))
        try database.raw("alter table \(Pivot<Post, Tag>.name) add \(tagAddKeySQL)")
    }
    
    static func revert(_ database: Database) throws {}
}
