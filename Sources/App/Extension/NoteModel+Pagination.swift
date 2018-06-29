import FluentMySQL
import Pagination
import Vapor

extension QueryBuilder where Result: DatabaseModel, Result: Paginatable, Result.Database == Database {
    
    func paginate(for request: Request) throws -> Future<Page<Result>> {
        let key = Pagination.defaultPageKey
        let field: KeyPath<Result, Date?> = \Result.createdAt
        let sorts = [MySQLDatabase.querySort(field.queryField, .descending)]
        let page = try request.query.get(Int?.self, at: key) ?? 1
        return try paginate(page: page, sorts)
    }
}

extension Page {
    
    func transform<T: PageResponse>(_ results: [T]) throws -> Page<T> {
        return try Page<T>(number: number, data: results, size: size, total: total)
    }
}
