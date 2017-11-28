import FluentProvider

extension PivotProtocol where Self: Entity {
    
    @discardableResult
    public static func attach(executor: Executor, _ left: Left, _ right: Right) throws -> Self {
        let leftId = try left.assertExists()
        let rightId = try right.assertExists()
        
        var row = Row()
        try row.set(leftIdKey, leftId)
        try row.set(rightIdKey, rightId)
        
        let pivot = try self.init(row: row)
        try pivot.makeQuery(executor).save()
        
        return pivot
    }
    
    public static func detach(executor: Executor, _ left: Left, _ right: Right) throws {
        let leftId = try left.assertExists()
        let rightId = try right.assertExists()
        
        try makeQuery(executor)
            .filter(leftIdKey, leftId)
            .filter(rightIdKey, rightId)
            .delete()
    }
}
