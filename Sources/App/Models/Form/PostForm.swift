import Vapor

struct PostForm: Form, Content {
    let title: String
    let content: String
    let category: Int?
    let tags: String
    let isStatic: Bool
    let isPublished: Bool
    let shouldTweet: Bool

    private enum CodingKeys: String, CodingKey {
        case title
        case content
        case category
        case tags
        case isStatic
        case isPublished
        case shouldTweet
    }

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
        if let bool = try? container.decode(Bool.self, forKey: .isPublished) {
            isPublished = bool
        } else {
            isPublished = (try? container.decode(String.self, forKey: .isPublished)) != nil
        }
        if let bool = try? container.decode(Bool.self, forKey: .shouldTweet) {
            shouldTweet = bool
        } else {
            shouldTweet = (try? container.decode(String.self, forKey: .shouldTweet)) != nil
        }
    }
}

extension PostForm: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("title", as: String.self, is: .count(1 ... Post.titleLength))
        validations.add("content", as: String.self, is: .count(1 ... Post.contentLength))
    }
}

extension PostForm {
    struct RenderingContext: Encodable {
        private enum ContainerKeys: String, CodingKey {
            case post
        }

        private enum CategoryKeys: String, CodingKey {
            case id
        }

        private enum CodingKeys: String, CodingKey {
            case title
            case content
            case category
            case tagsString
            case isStatic
            case isPublished
        }

        let form: PostForm

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: ContainerKeys.self)
            var nested = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .post)
            try nested.encode(form.title, forKey: .title)
            try nested.encode(form.content, forKey: .content)
            try nested.encode(form.tags, forKey: .tagsString)
            try nested.encode(form.isStatic, forKey: .isStatic)
            try nested.encode(form.isPublished, forKey: .isPublished)
            if let category = form.category {
                var categoryContainer = nested.nestedContainer(keyedBy: CategoryKeys.self, forKey: .category)
                try categoryContainer.encode(category, forKey: .id)
            }
        }
    }

    func makeRenderingContext() throws -> Encodable {
        return RenderingContext(form: self)
    }
}
