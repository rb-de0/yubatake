import Vapor

final class AdminViewContext {
    
    // MARK: - Class
    
    private static var viewRenderer: ViewRenderer!
    
    class func setUp(viewRenderer: ViewRenderer) {
        self.viewRenderer = viewRenderer
    }
    
    // MARK: - Instance
    
    private let title: String
    private let menuType: AdminMenuType
    
    init(title: String? = nil, menuType: AdminMenuType) {
        self.title = title ?? ""
        self.menuType = menuType
    }
    
    func formView(_ path: String, context: NodeRepresentable = Node(ViewContext.shared), for request: Request) throws -> View {
        
        var node = try context.makeNode(in: ViewContext.shared)
        
        try node.set("menuType", menuType.rawValue)
        
        return try type(of: self).viewRenderer.make(path, node, for: request)
    }
}
