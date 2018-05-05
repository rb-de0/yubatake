import CSRF
import Leaf
import Vapor

final class ViewCreator: Service {
    
    let renderer: TemplateRenderer
    let decorators: [ViewDecorator]
    
    init(renderer: TemplateRenderer, decorators: [ViewDecorator]) {
        self.renderer = renderer
        self.decorators = decorators
    }
    
    func make<T: Encodable>(_ path: String, _ encodable: T, for request: Request) throws -> Future<View> {
        
        func render(templateData: TemplateData) throws -> Future<View> {
            
            guard var context = templateData.dictionary else {
                throw Abort(.internalServerError)
            }
            
            try decorators.forEach { decorator in
                try decorator.decorate(context: &context, for: request)
            }
            
            return renderer.render(path, .dictionary(context))
        }
        
        return try TemplateDataEncoder().encode(encodable, on: request)
            .flatMap { templateData in
                try render(templateData: templateData)
            }
    }
}


// MARK: - Default
extension ViewCreator {
    
    class func `default`(container: Container) throws -> ViewCreator {
        return ViewCreator(renderer: try container.make(), decorators: [MessageDeliveryViewDecorator(), CSRFViewDecorator()])
    }
}
