import Vapor

final class PublicViewContext {

    private let title: String?
    private let path: String

    init(path: String, title: String? = nil) {
        self.path = path
        self.title = title
    }

    func makeResponse(context: Encodable = [String: String](), for request: Request) throws -> EventLoopFuture<View> {
        let config = request.application.applicationConfig
        let fileConfig = request.application.fileConfig
        return SiteInfo.shared(on: request.db)
            .and(Post.recentPosts(on: request.db))
            .and(Post.staticContents(on: request.db)).map { ($0.0.0, $0.0.1, $0.1) }
            .and(Tag.numberOfPosts(on: request.db)).map { ($0.0.0, $0.0.1, $0.0.2, $0.1) }
            .and(Category.numberOfPosts(on: request.db)).map { ($0.0.0, $0.0.1, $0.0.2, $0.0.3, $0.1) }
            .flatMap { [path, title] siteInfo, recentPosts, staticContents, tags, categories in
                let context = RenderingContext(
                    context: context,
                    pageTitle: title,
                    pageURL: request.url.string,
                    config: config,
                    fileConfig: fileConfig,
                    siteInfo: siteInfo,
                    recentPosts: recentPosts,
                    staticContents: staticContents,
                    tags: tags,
                    categories: categories
                )
                return request.application.viewCreator.create(path: path,
                                                              context: context,
                                                              siteInfo: siteInfo,
                                                              forAdmin: false,
                                                              for: request)
            }
    }
}

private extension PublicViewContext {
    struct RenderingContext: Encodable {
        let context: Encodable
        let pageTitle: String?
        let pageURL: String
        let config: ApplicationConfig
        let fileConfig: FileConfig
        let siteInfo: SiteInfo
        let recentPosts: [Post]
        let staticContents: [Post]
        let tags: [Tag.NumberOfPosts]
        let categories: [Category.NumberOfPosts]

        enum CodingKeys: String, CodingKey {
            case pageTitle
            case pageURL
            case siteInfo
            case recentPosts
            case staticContents
            case tags = "allTags"
            case categories = "allCategories"
            case meta
            case favicon
            case dateFormat
            case root
        }

        func encode(to encoder: Encoder) throws {
            try context.encode(to: encoder)
            var container = encoder.container(keyedBy: CodingKeys.self)
            let title = pageTitle ?? siteInfo.name
            let root = fileConfig.themeRoot.started(with: "/").finished(with: "/").appending(siteInfo.selectedTheme)
            try container.encode(title, forKey: .pageTitle)
            try container.encode(pageURL, forKey: .pageURL)
            try container.encode(siteInfo, forKey: .siteInfo)
            try container.encode(recentPosts, forKey: .recentPosts)
            try container.encode(staticContents, forKey: .staticContents)
            try container.encode(tags, forKey: .tags)
            try container.encode(categories, forKey: .categories)
            try container.encodeIfPresent(config.meta, forKey: .meta)
            try container.encodeIfPresent(config.faviconPath, forKey: .favicon)
            try container.encode(config.dateFormat, forKey: .dateFormat)
            try container.encode(root, forKey: .root)
        }
    }
}
