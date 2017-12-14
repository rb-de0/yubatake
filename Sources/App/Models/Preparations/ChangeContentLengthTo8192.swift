import FluentProvider

struct ChangeContentLengthTo8192: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.raw("alter table posts modify column content varchar(8192) not null")
    }
    
    static func revert(_ database: Database) throws {
        try database.raw("alter table posts modify column content varchar(255) not null")
    }
}

