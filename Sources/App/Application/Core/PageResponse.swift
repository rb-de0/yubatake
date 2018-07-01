import FluentMySQL
import Pagination
import Vapor

protocol PageResponse: Paginatable, MySQLModel, Content {}

extension PageResponse {
    
    init(from decoder: Decoder) throws { fatalError() }
    
    static var defaultPageSorts: [MySQLDatabase.QuerySort] {
        return []
    }

    var id: Int? {
        get {
            fatalError()
        }
        set {
            fatalError()
        }
    }
}
