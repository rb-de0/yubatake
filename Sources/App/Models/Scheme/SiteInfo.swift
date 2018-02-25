import FluentProvider
import HTTP
import ValidationProvider
import Vapor

final class SiteInfo: Model {
    
    static let idKey = "id"
    static let nameKey = "name"
    static let descriptionKey = "description"
    
    let storage = Storage()
    
    var name: String
    var description: String
    
    init(name: String, description: String) {
        self.name = name
        self.description = description
    }
    
    init(row: Row) throws {
        name = try row.get(SiteInfo.nameKey)
        description = try row.get(SiteInfo.descriptionKey)
    }
    
    func validate() throws {
        try name.validated(by: Count.containedIn(low: 1, high: 32))
        try description.validated(by: Count.containedIn(low: 1, high: 128))
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(SiteInfo.nameKey, name)
        try row.set(SiteInfo.descriptionKey, description)
        return row
    }
    
    static func shared() throws -> SiteInfo {
        
        guard let siteInfo = try SiteInfo.find(1) else {
            throw Abort(.internalServerError)
        }
        
        return siteInfo
        
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
        
        try validate()
    }
    
    static var updateableKeys: [UpdateableKey<SiteInfo>] {
        return []
    }
}
