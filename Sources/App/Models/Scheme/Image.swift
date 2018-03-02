import Crypto
import FluentProvider
import HTTP
import ValidationProvider
import Vapor

final class Image: Model {
    
    static let idKey = "id"
    static let nameKey = "name"
    static let pathKey = "path"
    static let altDescriptionKey = "alt_description"
    
    private lazy var imageRepository = resolve(ImageRepository.self)
    
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
        try imageRepository.deleteImage(at: path)
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
        
        let config = Configs.resolve(FileConfig.self)
        let basePath = config.imageRelativePath.started(with: "/").finished(with: "/")
        
        var row = try makeRow()
        try row.set(Image.idKey, id)
        try row.set(Image.nameKey, String(path.dropFirst(basePath.count)))
        
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
        
        guard let _name = req.data[ImageData.imageNameKey]?.string,
            let _altDescription = req.data[Image.altDescriptionKey]?.string else {
                
            throw Abort(.badRequest)
        }
        
        let config = Configs.resolve(FileConfig.self)
        let afterPath = config.imageRelativePath.started(with: "/").finished(with: "/").appending(_name)
        
        path = afterPath
        altDescription = _altDescription
    }
    
    static var updateableKeys: [UpdateableKey<Image>] {
        return []
    }
}

