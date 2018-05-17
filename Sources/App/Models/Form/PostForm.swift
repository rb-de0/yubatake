import Vapor

struct PostForm: Form, Content {
    
    struct RenderingContext: Encodable {
        
        private enum ContainerKeys: String, CodingKey {
            case post
        }
        
        private enum CodingKeys: String, CodingKey {
            case title
            case content
            case category
            case tagsString = "tags_string"
            case isStatic = "is_static"
        }
        
        private enum CategoryKeys: String, CodingKey {
            case id
        }
        
        let form: PostForm
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: ContainerKeys.self)
            var nested = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .post)

            try nested.encode(form.title, forKey: .title)
            try nested.encode(form.content, forKey: .content)
            try nested.encode(form.tags, forKey: .tagsString)
            try nested.encode(form.isStatic, forKey: .isStatic)
            
            if let category = form.category {
                var categoryContainer = nested.nestedContainer(keyedBy: CategoryKeys.self, forKey: .category)
                try categoryContainer.encode(category, forKey: .id)
            }
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case title
        case content
        case category
        case tags
        case isStatic = "is_static"
        case shouldTweet = "should_tweet"
    }
    
    let title: String
    let content: String
    let category: Int?
    let tags: String
    let isStatic: Bool
    let shouldTweet: Bool
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        category = (try? container.decodeIfPresent(Int.self, forKey: .category)) ?? nil
        tags = try container.decode(String.self, forKey: .tags)
        
        if let bool = try? container.decode(Bool.self, forKey: .isStatic) {
            isStatic = bool
        } else {
            isStatic = (try? container.decode(String.self, forKey: .isStatic)) != nil
        }
        
        if let bool = try? container.decode(Bool.self, forKey: .shouldTweet) {
            shouldTweet = bool
        } else {
            shouldTweet = (try? container.decode(String.self, forKey: .shouldTweet)) != nil
        }
    }
    
    func makeRenderingContext() throws -> Encodable {
        return RenderingContext(form: self)
    }
}
