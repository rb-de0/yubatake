import FluentMySQL
import Foundation
import Vapor

protocol DatabaseModel: MySQLModel, Timestampable, Parameter {
    var createdAt: Date? { get set }
    var updatedAt: Date? { get set }
}

extension DatabaseModel {
    static var createdAtKey: CreatedAtKey { return \.createdAt }
    static var updatedAtKey: UpdatedAtKey { return \.updatedAt }
    
    static var uniqueSlug: String {
        return ":id"
    }
}
