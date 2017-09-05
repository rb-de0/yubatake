import Vapor

// View base for develop
final class ViewRoutes: RouteCollection {
    
    private let view: ViewRenderer
    
    init(view: ViewRenderer) {
        self.view = view
    }
    
    func build(_ builder: RouteBuilder) throws {
        
        builder.get("admin/login") { _ in try self.view.make("admin/login") }
        builder.get("admin/posts") { _ in try self.view.make("admin/posts") }
    }
}
