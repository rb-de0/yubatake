import Vapor
import FluentProvider
import HTTP

final class SiteInfo: Model {
    
    static let idKey = "id"
    static let nameKey = "name"
    static let descriptionKey = "description"
    
    let storage = Storage()
    
    var name: String
    var description: String
    
    init(request: Request) {
        name = request.data[SiteInfo.nameKey]?.string ?? ""
        description = request.data[SiteInfo.descriptionKey]?.string ?? ""
    }
    
    init(row: Row) throws {
        name = try row.get(SiteInfo.nameKey)
        description = try row.get(SiteInfo.descriptionKey)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(SiteInfo.nameKey, name)
        try row.set(SiteInfo.descriptionKey, description)
        return row
    }
    
    static func shared() throws -> SiteInfo? {
        return try SiteInfo.find(1)
    }
}

// MARK: - Preparation
extension SiteInfo: Preparation {
    
    static func prepare(_ database: Database) throws {
        
        try database.create(self) { builder in
            builder.id()
            builder.string(SiteInfo.nameKey)
            builder.string(SiteInfo.descriptionKey)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: - JSONRepresentable
extension SiteInfo: JSONRepresentable {
    
    func makeJSON() throws -> JSON {
        var row = try makeRow()
        try row.set(SiteInfo.idKey, id)
        return JSON(row)
    }
}

// MARK: - SiteInfo
extension SiteInfo: ResponseRepresentable {}


// MARK: - Timestampable
extension SiteInfo: Timestampable {}

// MARK: - Updateable
extension SiteInfo: Updateable {
    
    func update(for req: Request) throws {
        name = req.data[SiteInfo.nameKey]?.string ?? ""
        description = req.data[SiteInfo.descriptionKey]?.string ?? ""
    }
    
    static var updateableKeys: [UpdateableKey<SiteInfo>] {
        return []
    }
}
