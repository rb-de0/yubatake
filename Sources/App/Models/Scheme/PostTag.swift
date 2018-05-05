import FluentMySQL

final class PostTag: ModifiablePivot, MySQLModel {
    
    private enum CodingKeys: String, CodingKey {
        case id
        case postId = "post_id"
        case tagId = "tag_id"
    }
    
    static var entity: String {
        return "post_tag"
    }
    
    static var leftIDKey: LeftIDKey {
        return \.postId
    }
    
    static var rightIDKey: RightIDKey {
        return \.tagId
    }
    
    typealias Left = Post
    typealias Right = Tag
    
    var id: Int?
    var postId: Int
    var tagId: Int
    
    init(_ left: Left, _ right: Right) throws {
        postId = try left.requireID()
        tagId = try right.requireID()
    }
}
