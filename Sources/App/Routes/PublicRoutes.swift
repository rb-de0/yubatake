import AuthProvider
import Vapor

final class PublicRoutes: RouteCollection, EmptyInitializable {
    
    func build(_ builder: RouteBuilder) throws {
        
        // Login
        
        let group = builder.grouped(InverseRedirectMiddleware<User>.home(path: "admin/posts"))
        group.resource("login", LoginController())
        
        // Logout
        
        builder.resource("logout", LogoutController())

        // Posts
        
        let controller = PostController()
        
        builder.resource("", controller)
        builder.resource("posts", controller)
        
        builder.get("tags", Tag.parameter, "posts") { request in
            let tag = try request.parameters.next(Tag.self)
            return try controller.index(request: request, inTag: tag)
        }
        
        builder.get("categories", Category.parameter, "posts") { request in
            let category = try request.parameters.next(Category.self)
            return try controller.index(request: request, inCategory: category)
        }
        
        builder.get("categories/noncategorized/posts") { request in
            return try controller.indexNoCategory(request: request)
        }
    }
}
