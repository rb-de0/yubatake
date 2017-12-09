import Vapor
import AuthProvider

final class AdminRoutes: RouteCollection, EmptyInitializable {
    
    func build(_ builder: RouteBuilder) throws {
        
        let secureGroup = builder.grouped([
            RedirectMiddleware.login(),
            PersistMiddleware<User>(),
            PasswordAuthenticationMiddleware<User>()
        ])
        
        let admin = secureGroup.grouped("admin")
        
        admin.editableResource("tags", AdminTagController())
        admin.editableResource("categories", AdminCategoryController())
        admin.editableResource("posts", AdminPostController())
        admin.resource("siteinfo/edit", AdminSiteInfoController())
        admin.resource("user/edit", AdminUserController())
    }
}
