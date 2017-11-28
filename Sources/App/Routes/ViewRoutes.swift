import Vapor

// View base for develop
final class ViewRoutes: RouteCollection {
    
    private let view: ViewRenderer
    
    init(view: ViewRenderer) {
        self.view = view
    }
    
    func build(_ builder: RouteBuilder) throws {
        
        // Admin
        builder.get("admin/login") { _ in try self.view.make("admin/login") }
        builder.get("admin/posts") { _ in try self.view.make("admin/posts") }
        builder.get("admin/tags") { _ in try self.view.make("admin/tags") }
        builder.get("admin/categories") { _ in try self.view.make("admin/categories") }
        builder.get("admin/new-post") { _ in try self.view.make("admin/new-post") }
        builder.get("admin/new-tag") { _ in try self.view.make("admin/new-tag") }
        builder.get("admin/new-category") { _ in try self.view.make("admin/new-category") }
        
        
        // Public
        builder.get("") { _ in try self.view.make("public/posts") }
        builder.get("/tag") { _ in try self.view.make("public/posts-in-a-tag") }
        builder.get("/category") { _ in try self.view.make("public/posts-in-a-category") }
        builder.get("/post") { _ in try self.view.make("public/post") }
    }
}

