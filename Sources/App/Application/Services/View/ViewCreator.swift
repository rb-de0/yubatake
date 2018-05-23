import CSRF
import Leaf
import Vapor

final class ViewCreator: Service {
    
    let decorators: [ViewDecorator]
    
    init(decorators: [ViewDecorator]) {
        self.decorators = decorators
    }
    
    func make<T: Encodable>(_ path: String, _ encodable: T, for request: Request, forAdmin: Bool) throws -> Future<View> {
        
        func render(templateData: TemplateData) throws -> Future<View> {
            
            guard var context = templateData.dictionary else {
                throw Abort(.internalServerError)
            }
            
            try decorators.forEach { decorator in
                try decorator.decorate(context: &context, for: request)
            }
            
            let base = try request.make(TemplateRenderer.self)
            
            if forAdmin {
                return base.render(path, .dictionary(context))
            }
            
            return try SiteInfo.shared(on: request).flatMap { siteInfo in
                let relativeDirectory = try request.make(FileConfig.self).templateDir(in: siteInfo.selectedTheme)
                let renderer: TemplateRenderer = PublicTemplateRenderer(base: base, relativeDirectory: relativeDirectory)
                return renderer.render(path, .dictionary(context))
            }
        }
        
        return try TemplateDataEncoder().encode(encodable, on: request)
            .flatMap { templateData in
                try render(templateData: templateData)
            }
    }
}


// MARK: - Default
extension ViewCreator {
    
    class func `default`(decorators: [ViewDecorator] = [MessageDeliveryViewDecorator(), CSRFViewDecorator()]) throws -> ViewCreator {
        return ViewCreator(decorators: decorators)
    }
}
