import FluentMySQL
import Foundation
import Vapor

protocol DatabaseModel: MySQLModel, Parameter {
    var createdAt: Date? { get set }
    var updatedAt: Date? { get set }
}

extension DatabaseModel {
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    
    static var uniqueSlug: String {
        return ":id"
    }
}
