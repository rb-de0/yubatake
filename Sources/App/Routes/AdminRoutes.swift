import Vapor

final class AdminRoutes: RouteCollection, EmptyInitializable {
    
    func build(_ builder: RouteBuilder) throws {
        
        let admin = builder.grouped("admin")
        
        admin.editableResource("tags", AdminTagController())
        admin.editableResource("categories", AdminCategoryController())
        admin.editableResource("posts", AdminPostController())
        admin.resource("siteinfo/edit", AdminSiteInfoController())
    }
}
