import Leaf
import Vapor

final class PublicViewContext {
    
    private struct RenderingContext: Encodable {
        
        let context: Encodable
        let pageTitle: String?
        let pageURL: String
        let config: ApplicationConfig
        let fileConfig: FileConfig
        let siteInfo: Future<SiteInfo>
        let recentPosts: Future<[Post]>
        let staticContents: Future<[Post]>
        let tags: Future<[Tag.NumberOfPosts]>
        let categories: Future<[Category.NumberOfPosts]>
        
        enum CodingKeys: String, CodingKey {
            case pageTitle = "page_title"
            case pageURL = "page_url"
            case siteInfo = "site_info"
            case recentPost = "recent_posts"
            case staticContents = "static_contents"
            case tags = "all_tags"
            case categories = "all_categories"
            case meta
            case dateFormat = "date_format"
            case favicon
            case root
        }
        
        func encode(to encoder: Encoder) throws {
            try context.encode(to: encoder)
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            let title = siteInfo.map { self.pageTitle ?? $0.name }
            let root = siteInfo.map { self.fileConfig.themeRoot.started(with: "/").finished(with: "/").appending($0.selectedTheme) }
            
            try container.encode(title, forKey: .pageTitle)
            try container.encode(pageURL, forKey: .pageURL)
            try container.encode(siteInfo, forKey: .siteInfo)
            try container.encode(recentPosts, forKey: .recentPost)
            try container.encode(staticContents, forKey: .staticContents)
            try container.encode(tags, forKey: .tags)
            try container.encode(categories, forKey: .categories)
            
            try container.encodeIfPresent(config.meta, forKey: .meta)
            try container.encodeIfPresent(config.faviconPath, forKey: .favicon)
            try container.encode(config.dateFormat, forKey: .dateFormat)
            
            try container.encode(root, forKey: .root)
            
        }
    }
    
    private let title: String?
    private let path: String
    
    init(path: String, title: String? = nil) {
        self.path = path
        self.title = title
    }
    
    func makeResponse(context: Encodable = [String: String](), for request: Request) throws -> Future<View> {
        
        let config = try request.make(ApplicationConfig.self)
        let fileConfig = try request.make(FileConfig.self)
        let siteInfo = try SiteInfo.shared(on: request)
        let recentPosts = try Post.recentPosts(on: request)
        let staticContents = try Post.staticContents(on: request)
        let tags = Tag.numberOfPosts(on: request)
        let categories = Category.numberOfPostsForAll(on: request)
        
        let renderingContext = RenderingContext(
            context: context,
            pageTitle: title,
            pageURL: request.http.urlString,
            config: config,
            fileConfig: fileConfig,
            siteInfo: siteInfo,
            recentPosts: recentPosts,
            staticContents: staticContents,
            tags: tags,
            categories: categories
        )
        
        return try request.make(ViewCreator.self).make(path, renderingContext, for: request, forAdmin: false)
    }
}
