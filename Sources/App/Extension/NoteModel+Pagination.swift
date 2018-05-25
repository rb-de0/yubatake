import Fluent
import Pagination
import Vapor

extension QueryBuilder where Model: DatabaseModel, Model: Paginatable {
    
    func paginate(for request: Request) throws -> Future<Page<Model>> {
        let key = Pagination.defaultPageKey
        let field: KeyPath<Model, Date?> = \Model.createdAt
        let sorts = [try QuerySort(field: field.makeQueryField(), direction: .descending)]
        let page = try request.query.get(Int?.self, at: key) ?? 1
        return try paginate(page: page, sorts)
    }
}

extension Page {
    
    func transform<T: PageResponse>(_ results: [T]) throws -> Page<T> {
        return try Page<T>(number: number, data: results, size: size, total: total)
    }
}
