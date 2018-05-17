import FluentMySQL

extension MySQLColumnDefinition {
    
    static func bool() -> MySQLColumnDefinition {
        return tinyInt(length: 1)
    }
}
