import Vapor

final class AdminViewContext {

    private let path: String
    private let menuType: AdminMenuType?
    private let title: String?

    init(path: String, menuType: AdminMenuType? = nil, title: String? = nil) {
        self.path = path
        self.menuType = menuType
        self.title = title
    }

    func makeResponse(context: Encodable = [String: String](), formDataType: Form.Type = EmptyForm.self, for request: Request) throws -> EventLoopFuture<View> {
        let config = request.application.applicationConfig
        let formData = try formDataType.restoreFormData(from: request)?.makeRenderingContext()
        return SiteInfo.shared(on: request.db)
            .flatMap { [path, menuType, title] siteInfo in
                let context = RenderingContext(
                    context: context,
                    pageTitle: title,
                    config: config,
                    siteInfo: siteInfo,
                    menuType: menuType,
                    formData: formData
                )
                return request.application.viewCreator.create(path: path,
                                                              context: context,
                                                              siteInfo: siteInfo,
                                                              forAdmin: true,
                                                              for: request)
            }
    }
}

private extension AdminViewContext {
    struct RenderingContext: Encodable {
        let context: Encodable
        let pageTitle: String?
        let config: ApplicationConfig
        let siteInfo: SiteInfo
        let menuType: AdminMenuType?
        let formData: Encodable?

        enum CodingKeys: String, CodingKey {
            case pageTitle
            case siteInfo
            case menuType
            case dateFormat
        }

        func encode(to encoder: Encoder) throws {
            try context.encode(to: encoder)
            try formData?.encode(to: encoder)
            let title = pageTitle ?? siteInfo.name
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(title, forKey: .pageTitle)
            try container.encode(siteInfo, forKey: .siteInfo)
            try container.encodeIfPresent(menuType?.rawValue, forKey: .menuType)
            try container.encode(config.dateFormat, forKey: .dateFormat)
        }
    }
}
