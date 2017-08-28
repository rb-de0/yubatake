import Vapor

// View base for develop
final class ViewRoutes: RouteCollection {
    
    private let view: ViewRenderer
    
    init(view: ViewRenderer) {
        self.view = view
    }
    
    func build(_ builder: RouteBuilder) throws {
        
        builder.get("login") { _ in try self.view.make("admin/login") }
    }
}
