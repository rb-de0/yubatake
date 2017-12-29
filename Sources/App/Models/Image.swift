import Crypto
import FluentProvider
import HTTP
import ValidationProvider
import Vapor

final class Image: Model {
    
    static let idKey = "id"
    static let pathKey = "path"
    static let altDescriptionKey = "alt_description"
    
    let storage = Storage()
    
    var path: String
    var altDescription: String
    
    init(data: ImageData) throws {
        path = data.path
        altDescription = data.name
    }
    
    init(row: Row) throws {
        path = try row.get(Image.pathKey)
        altDescription = try row.get(Image.altDescriptionKey)
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Image.pathKey, path)
        try row.set(Image.altDescriptionKey, altDescription)
        return row
    }
    
    func deleteImageData() throws {
        try FileHelper.deleteImage(at: path)
    }
}

// MARK: - Preparation
extension Image: Preparation {
    
    static func prepare(_ database: Database) throws {
        
        try database.create(self) { builder in
            builder.id()
            builder.string(Image.pathKey, unique: true)
            builder.string(Image.altDescriptionKey)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: - JSONRepresentable
extension Image: JSONRepresentable {
    
    func makeJSON() throws -> JSON {
        var row = try makeRow()
        try row.set(Image.idKey, id)
        return JSON(row)
    }
}

// MARK: - SiteInfo
extension Image: ResponseRepresentable {}

// MARK: - Timestampable
extension Image: Timestampable {}

// MARK: - Paginatable
extension Image: Paginatable {
    
    static var defaultPageSize: Int {
        return 32
    }
}

// MARK: - Updateable
extension Image: Updateable {
    
    func update(for req: Request) throws {
        altDescription = req.data[Image.altDescriptionKey]?.string ?? ""
    }
    
    static var updateableKeys: [UpdateableKey<Image>] {
        return []
    }
}

