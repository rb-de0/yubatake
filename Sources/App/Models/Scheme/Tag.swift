import FluentMySQL
import Pagination
import Vapor

final class Tag: DatabaseModel, Content {
    
    struct NumberOfPosts: Content {
        let tag: Tag
        let count: Int
    }
    
    static let separator = ","
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    static let nameLength = 16
    
    var id: Int?
    var name: String
    var createdAt: Date?
    var updatedAt: Date?
    
    private init(name: String) {
        self.name = name
    }
    
    init(from form: TagForm) throws {
        name = form.name
        try validate()
    }
    
    func apply(form: TagForm) throws -> Self  {
        name = form.name
        try validate()
        return self
    }
    
    // MARK: - Static
    
    static func tags(from form: PostForm) throws -> [Tag] {
        let tagStrings = form.tags.components(separatedBy: Tag.separator)
        return tagStrings.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.map { Tag(name: $0) }
    }
    
    static func notInsertedTags(in tags: [Tag], on conn: DatabaseConnectable) throws -> Future<[Tag]> {
        return try tags
            .map { tag in try Tag.query(on: conn).filter(\Tag.name == tag.name).count().map { count in (count, tag) } }
            .flatten(on: conn)
            .map { tags in tags.filter { $0.0 == 0 }.map { $0.1 } }
    }
    
    static func insertedTags(in tags: [Tag], on conn: DatabaseConnectable) throws -> Future<[Tag]> {
        return try tags.map { try Tag.query(on: conn).filter(\Tag.name == $0.name).first() }
            .flatten(on: conn)
            .map { tags in tags.compactMap { $0 } }
    }
    
    static func numberOfPosts(on conn: DatabaseConnectable, count: Int = 10) -> Future<[NumberOfPosts]> {
        
        return Tag.query(on: conn).all()
            .flatMap { tags in
                let counts = try tags.compactMap { tag in
                    try tag.posts.query(on: conn).noStaticAll().count().map {
                        NumberOfPosts(tag: tag, count: $0)
                    }
                }
                return counts.flatten(on: conn)
                    .map { $0.filter { $0.count > 0 }.sorted(by: { $0.count > $1.count }).take(n: count) }
            }
    }
}

// MARK: - Relation
extension Tag {

    var posts: Siblings<Tag, Post, PostTag> {
        return siblings()
    }
}

// MARK: - Paginatable
extension Tag: Paginatable {}

// MARK: - Validatable
extension Tag: Validatable {
    
    static func validations() throws -> Validations<Tag> {
        var validations = Validations(Tag.self)
        try validations.add(\.name, .count(1...Tag.nameLength))
        return validations
    }
}
