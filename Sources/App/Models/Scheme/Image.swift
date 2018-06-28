import FluentMySQL
import Pagination
import Vapor

final class Image: DatabaseModel {
    
    static let entity = "images"
    static let defaultPageSize = 32
    
    struct Public: ResponseContent {
        
        private enum CodingKeys: String, CodingKey {
            case name
        }
        
        let image: Image
        let name: String
        
        func encode(to encoder: Encoder) throws {
            try image.encode(to: encoder)
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case path
        case altDescription = "alt_description"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    var id: Int?
    var path: String
    var altDescription: String
    var createdAt: Date?
    var updatedAt: Date?
    
    init(from form: ImageUploadForm, on container: Container) throws {
        let relativePath = try container.make(FileConfig.self).imageRoot
        self.path = relativePath.started(with: "/").finished(with: "/").appending(form.name)
        self.altDescription = form.name
    }
    
    func formPublic(on container: Container) throws -> Public {
        let relativePath = try container.make(FileConfig.self).imageRoot
        let basePath = relativePath.started(with: "/").finished(with: "/")
        return Public(image: self, name: String(path.dropFirst(basePath.count)))
    }
    
    func apply(form: ImageForm, on container: Container) throws -> Self {
        let relativePath = try container.make(FileConfig.self).imageRoot
        self.path = relativePath.started(with: "/").finished(with: "/").appending(form.name)
        self.altDescription = form.altDescription
        return self
    }
}

// MARK: - Paginatable
extension Image: Paginatable {}
