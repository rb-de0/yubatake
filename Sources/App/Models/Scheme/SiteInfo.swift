import FluentMySQL
import Vapor

final class SiteInfo: DatabaseModel, Content {
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    static let nameLength = 32
    static let descriptionLength = 128
    
    var id: Int?
    var name: String
    var description: String
    var createdAt: Date?
    var updatedAt: Date?
    
    init(name: String, description: String) {
        self.name = name
        self.description = description
    }
    
    func apply(form: SiteInfoForm) throws -> Self {
        name = form.name
        description = form.description
        try validate()
        return self
    }
    
    static func shared(on conn: DatabaseConnectable) throws -> Future<SiteInfo> {
        return try SiteInfo.find(1, on: conn).unwrap(or: Abort(.internalServerError))
    }
}

// MARK: - Validatable
extension SiteInfo: Validatable {
    
    static func validations() throws -> Validations<SiteInfo> {
        var validations = Validations(SiteInfo.self)
        try validations.add(\.name, .count(1...SiteInfo.nameLength))
        try validations.add(\.description, .count(1...SiteInfo.descriptionLength))
        return validations
    }
}
