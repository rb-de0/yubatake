import CSRF
import Vapor

final class PublicViewContext {
    
    private var title: String?
    private let path: String
    
    init(path: String, title: String? = nil) {
        self.path = path
        self.title = title
    }
    
    func addTitle(_ title: String?) -> Self {
        self.title = title
        return self
    }
    
    func makeResponse(context: NodeRepresentable = Node(ViewContext.shared), for request: Request) throws -> View {
        
        var node = try context.makeNode(in: ViewContext.shared)
        
        // common data
        let siteInfo = try SiteInfo.shared()
        try node.set("site_info", siteInfo.makeJSON())
        try node.set("recent_posts", try Post.recentPosts().makeJSON())
        try node.set("static_contents", try Post.staticContents().makeJSON())
        
        // page informations
        let config = Configs.resolve(ApplicationConfig.self)
        try node.set("page_title", title ?? siteInfo.name)
        try node.set("page_url", request.uri.makeFoundationURL().absoluteString)
        try node.set("meta", config.meta?.makeJSON())
        
        // tags
        try node.set("all_tags", try Tag.numberOfPosts().makeJSON())
        
        // categories
        try node.set("all_categories", try Category.numberOfPostsForAll().makeJSON())
        
        return try resolve(ViewCreator.self).make(path, node, for: request)
    }
}
