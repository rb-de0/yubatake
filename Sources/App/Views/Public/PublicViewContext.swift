import Vapor

final class PublicViewContext {
    
    // MARK: - Class
    
    private static var viewRenderer: ViewRenderer!
    
    class func setUp(viewRenderer: ViewRenderer) {
        self.viewRenderer = viewRenderer
    }
    
    // MARK: - Instance
    
    private let title: String
    
    init(title: String? = nil) {
        self.title = title ?? ""
    }
    
    func formView(_ path: String, context: NodeRepresentable = Node(ViewContext.shared), for request: Request) throws -> View {
        
        var node = try context.makeNode(in: ViewContext.shared)
        
        try node.set("site_info", SiteInfo.shared()?.makeJSON())
        
        return try type(of: self).viewRenderer.make(path, node, for: request)
    }
}
