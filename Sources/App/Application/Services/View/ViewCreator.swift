import CSRF
import Leaf
import Vapor

final class ViewCreator: Service {
    
    private let publicRenderer: PublicTemplateRenderer
    private let lock = NSLock()
    
    let decorators: [ViewDecorator]
    
    init(publicRenderer: PublicTemplateRenderer, decorators: [ViewDecorator]) {
        self.publicRenderer = publicRenderer
        self.decorators = decorators
    }
    
    func updateDirectory(to name: String, on container: Container) throws {
        lock.lock()
        defer { lock.unlock() }
        publicRenderer.updateDirectory(to: try container.make(FileConfig.self).templateDir(in: name))
    }
    
    func make<T: Encodable>(_ path: String, _ encodable: T, for request: Request, forAdmin: Bool) throws -> Future<View> {
        
        let renderer: TemplateRenderer = forAdmin ? try request.make(TemplateRenderer.self) : publicRenderer
        
        func render(templateData: TemplateData) throws -> Future<View> {
            
            guard var context = templateData.dictionary else {
                throw Abort(.internalServerError)
            }
            
            try decorators.forEach { decorator in
                try decorator.decorate(context: &context, for: request)
            }
            
            lock.lock()
            defer { lock.unlock() }
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
    
    class func `default`(container: Container, decorators: [ViewDecorator] = [MessageDeliveryViewDecorator(), CSRFViewDecorator()]) throws -> ViewCreator {
        let relativeDirectory = try container.make(FileConfig.self).templateDir(in: SiteInfo.defaultTheme)
        let publicRenderer = PublicTemplateRenderer(base: try container.make(), relativeDirectory: relativeDirectory)
        return ViewCreator(publicRenderer: publicRenderer, decorators: decorators)
    }
}
