import CSRF
import Vapor

final class AdminViewContext: ApplicationHelper {
    
    // MARK: - Class
    
    private static var viewRenderer: ViewRenderer!
    
    static func setup(_ drop: Droplet) {
        viewRenderer = drop.view
    }
    
    // MARK: - Instance
    
    private let path: String
    private let formDataDeliverer: FormDataDeliverable.Type
    
    private var menuType: AdminMenuType?
    private var title: String?
    
    init(path: String, menuType: AdminMenuType? = nil, title: String? = nil, formDataDeliverer: FormDataDeliverable.Type = NoDerivery.self) {
        self.path = path
        self.menuType = menuType
        self.title = title
        self.formDataDeliverer = formDataDeliverer
    }
    
    func addTitle(_ title: String) -> Self {
        self.title = title
        return self
    }
    
    func addMenu(_ menuType: AdminMenuType) -> Self {
        self.menuType = menuType
        return self
    }
    
    func makeResponse(context: NodeRepresentable = Node(ViewContext.shared), for request: Request) throws -> View {
        
        var node = try context.makeNode(in: ViewContext.shared)
        
        let siteInfo = try SiteInfo.shared()
        try node.set("csrf_token", try CSRF().createToken(from: request))
        try node.set("menu_type", menuType?.rawValue)
        try node.set("page_title", title ?? siteInfo.name)
        
        if let redirectFormData = (request.storage[formDataDeliverer.formDataKey] as? Node)?.object {
            try formDataDeliverer.override(node: &node, with: redirectFormData)
        }
        
        do {
            let view = try type(of: self).viewRenderer.make(FileHelper.userDirectoryName.finished(with: "/") + path, node, for: request)
            return view
        } catch let error as DataFileError {
            if case .load(_) = error {
                return try type(of: self).viewRenderer.make(path, node, for: request)
            } else {
                throw error
            }
        } catch {
            throw error
        }
    }
}
