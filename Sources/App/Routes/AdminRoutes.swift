import Authentication
import Vapor

final class AdminRoutes: RouteCollection {
    
    func boot(router: Router) throws {
                
        // login
        do {
            let controller = LoginController()
            router.get("login", use: controller.index)
            router.post(LoginForm.self, at: "login", use: controller.store)
        }
        
        // logout
        do {
            let controller = LogoutController()
            router.get("logout", use: controller.index)
        }
        
        // protect
        let admin = router
            .grouped("admin")
            .grouped(RedirectMiddleware<User>.login())
        
        // posts
        do {
            let controller = AdminPostController()
            admin.get("posts", use: controller.index)
            admin.get("static-contents", use: controller.indexStaticContent)
            admin.get("posts/create", use: controller.create)
            admin.get("posts", Post.parameter, "edit", use: controller.edit)
            admin.post(PostForm.self, at: "posts", use: controller.store)
            admin.post(PostForm.self, at: "posts", Post.parameter, "edit", use: controller.update)
            admin.post(DeletePostsForm.self, at: "posts/delete", use: controller.delete)
            
            admin.get("posts", Post.parameter, "preview", use: controller.showPreview)
        }
        
        // categories
        do {
            let controller = AdminCategoryController()
            admin.get("categories", use: controller.index)
            admin.get("categories/create", use: controller.create)
            admin.get("categories", Category.parameter, "edit", use: controller.edit)
            admin.post(CategoryForm.self, at: "categories", use: controller.store)
            admin.post(CategoryForm.self, at: "categories", Category.parameter, "edit", use: controller.update)
            admin.post(DeleteCategoriesForm.self, at: "categories/delete", use: controller.delete)
        }
        
        // tags
        do {
            let controller = AdminTagController()
            admin.get("tags", use: controller.index)
            admin.get("tags/create", use: controller.create)
            admin.get("tags", Tag.parameter, "edit", use: controller.edit)
            admin.post(TagForm.self, at: "tags", use: controller.store)
            admin.post(TagForm.self, at: "tags", Tag.parameter, "edit", use: controller.update)
            admin.post(DeleteTagsForm.self, at: "tags/delete", use: controller.delete)
        }
        
        // images
        do {
            let controller = AdminImageViewController()
            admin.get("images", use: controller.index)
            admin.get("images", Image.parameter, "edit", use: controller.edit)
            admin.post(ImageForm.self, at: "images", Image.parameter, "edit", use: controller.update)
            admin.post("images", Image.parameter, "delete", use: controller.delete)
            admin.post("images/cleanup", use: controller.cleanup)
        }
        
        // themes
        do {
            let controller = AdminThemeController()
            admin.get("themes", use: controller.index)
        }
        
        // site
        do {
            let controller = AdminSiteInfoController()
            admin.get("siteinfo/edit", use: controller.index)
            admin.post(SiteInfoForm.self, at: "siteinfo/edit", use: controller.store)
        }
        
        // user
        do {
            let controller = AdminUserController()
            admin.get("user/edit", use: controller.index)
            admin.post(UserForm.self, at: "user/edit", use: controller.store)
        }
    }
}
