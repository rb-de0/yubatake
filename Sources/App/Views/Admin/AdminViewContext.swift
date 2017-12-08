import Vapor

final class AdminViewContext {
    
    // MARK: - Class
    
    private static var viewRenderer: ViewRenderer!
    
    class func setUp(viewRenderer: ViewRenderer) {
        self.viewRenderer = viewRenderer
    }
    
    // MARK: - Instance
    
    private let menuType: AdminMenuType
    private let path: String
    
    private var title: String?
    
    init(path: String, menuType: AdminMenuType, title: String? = nil) {
        self.path = path
        self.menuType = menuType
        self.title = title
    }
    
    func addTitle(_ title: String) -> Self {
        self.title = title
        return self
    }
    
    func makeResponse(context: NodeRepresentable = Node(ViewContext.shared), for request: Request) throws -> View {
        
        var node = try context.makeNode(in: ViewContext.shared)
        
        try node.set("menu_type", menuType.rawValue)
        
        return try type(of: self).viewRenderer.make(path, node, for: request)
    }
}
