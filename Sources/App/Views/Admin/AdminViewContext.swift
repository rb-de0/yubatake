import Leaf
import Vapor

final class AdminViewContext {
    
    private struct RenderingContext: Encodable {
        
        let context: Encodable
        let pageTitle: String?
        let siteInfo: Future<SiteInfo>
        let menuType: AdminMenuType?
        let formData: Encodable?
        
        enum CodingKeys: String, CodingKey {
            case pageTitle = "page_title"
            case siteInfo = "site_info"
            case menuType = "menu_type"
        }
        
        func encode(to encoder: Encoder) throws {
            
            let title = siteInfo.map { self.pageTitle ?? $0.name }
            
            try context.encode(to: encoder)
            try formData?.encode(to: encoder)
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(title, forKey: .pageTitle)
            try container.encode(siteInfo, forKey: .siteInfo)
            try container.encode(menuType?.rawValue, forKey: .menuType)
        }
    }
    
    private let path: String
    private let menuType: AdminMenuType?
    private let title: String?
    
    init(path: String, menuType: AdminMenuType? = nil, title: String? = nil) {
        self.path = path
        self.menuType = menuType
        self.title = title
    }
    
    func makeResponse(context: Encodable = [String: String](), formDataType: Form.Type = EmptyForm.self, for request: Request) throws -> Future<View> {
        
        let formData = try formDataType.restoreFormData(from: request)?.makeRenderingContext()
        let siteInfo = try SiteInfo.shared(on: request)
        
        let renderingContext = RenderingContext(
            context: context,
            pageTitle: title,
            siteInfo: siteInfo,
            menuType: menuType,
            formData: formData
        )
        
        return try request.make(ViewCreator.self).make(path, renderingContext, for: request)
    }
}
