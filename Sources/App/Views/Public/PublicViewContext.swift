import Vapor

final class PublicViewContext: ApplicationHelper {
    
    // MARK: - Class
    
    private static var viewRenderer: ViewRenderer!
    
    static func setup(_ drop: Droplet) {
        viewRenderer = drop.view
    }
    
    // MARK: - Instance
    
    private let title: String
    private let path: String
    
    init(path: String, title: String? = nil) {
        self.path = path
        self.title = title ?? ""
    }
    
    func makeResponse(context: NodeRepresentable = Node(ViewContext.shared), for request: Request) throws -> View {
        
        var node = try context.makeNode(in: ViewContext.shared)
        
        try node.set("site_info", SiteInfo.shared().makeJSON())
        
        return try type(of: self).viewRenderer.make(path, node, for: request)
    }
}
