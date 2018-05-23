import FluentMySQL
import Pagination
import Vapor

final class Category: DatabaseModel, Content {
    
    struct NumberOfPosts: Content {
        let category: Category
        let count: Int
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    static let nameLength = 32
    
    var id: Int?
    var name: String
    var createdAt: Date?
    var updatedAt: Date?
    
    private init(name: String) {
        self.name = name
    }
    
    init(from form: CategoryForm) throws {
        name = form.name
        try validate()
    }
    
    func apply(form: CategoryForm) throws -> Self  {
        name = form.name
        try validate()
        return self
    }
    
    static func numberOfPostsForAll(on conn: DatabaseConnectable) -> Future<[NumberOfPosts]> {
        
        return Category.query(on: conn).all()
            .flatMap { categories in
                let counts = try categories.compactMap { category in
                    try category.posts.query(on: conn).publicAll().noStaticAll().count().map {
                        NumberOfPosts(category: category, count: $0)
                    }
                }
                return counts.flatten(on: conn)
                    .map { $0.filter { $0.count > 0 }.sorted(by: { $0.count > $1.count }) }
                }
    }
    
    static func makeNonCategorized() -> Category {
        return Category(name: "NonCategorized")
    }
}


// MARK: - Relation
extension Category {
    
    var posts: Children<Category, Post> {
        return children(\Post.categoryId)
    }
}

// MARK: - Paginatable
extension Category: Paginatable {}

// MARK: - Validatable
extension Category: Validatable {
    
    static func validations() throws -> Validations<Category> {
        var validations = Validations(Category.self)
        try validations.add(\.name, .count(1...Category.nameLength))
        return validations
    }
}
