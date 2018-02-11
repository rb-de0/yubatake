import CSRF
import Vapor

final class AdminViewContext {
    
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
        try node.set("menu_type", menuType?.rawValue)
        try node.set("page_title", title ?? siteInfo.name)

        return try resolve(ViewCreator.self).make(path, node, for: request, formDataDeliverer: formDataDeliverer)
    }
}
