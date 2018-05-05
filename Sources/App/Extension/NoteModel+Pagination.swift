import Fluent
import Pagination
import Vapor

extension QueryBuilder where Model: DatabaseModel, Model: Paginatable {
    
    func paginate(for request: Request, key: String = Pagination.defaultPageKey) throws -> Future<Page<Model>> {
        
        let page = try request.query.get(Int?.self, at: key) ?? 1
        let pageSize = Model.defaultPageSize
        let lower = pageSize * (page - 1)
        let upper = page * pageSize
        
        let countBuilder = Model.query(on: request)
        countBuilder.query = query
        
        let resultsBuilder = Model.query(on: request)
        resultsBuilder.query = query
        
        let totalCount = countBuilder.count()
        let results = try resultsBuilder
            .sort(\Model.createdAt, .descending)
            .range(lower: lower, upper: upper)
            .all()
        
        return totalCount.and(results)
            .map { data in
                let (total, results) = data
                return try Page<Model>(
                    number: page,
                    data: results,
                    size: pageSize,
                    total: total
                )
        }
    }
}

extension Page {
    
    func transform<T: PageResponse>(_ results: [T]) throws -> Page<T> {
        return try Page<T>(number: number, data: results, size: size, total: total)
    }
}
