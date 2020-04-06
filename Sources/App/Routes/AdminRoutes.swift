import Vapor

final class AdminRoutes: RouteCollection {

    func boot(routes: RoutesBuilder) throws {

        // login
        do {
            let controller = LoginController()
            routes.get("login", use: controller.index)
            routes.post("login", use: controller.store)
        }

        // logout
        do {
            let controller = LogoutController()
            routes.get("logout", use: controller.index)
        }

        // protect
        let admin = routes.grouped("admin")
            .grouped(User.redirectMiddleware(path: "/login"))

        // posts
        do {
            let controller = AdminPostController()
            admin.get("posts", use: controller.index)
            admin.get("static-contents", use: controller.indexStaticContent)
            admin.get("posts", "create", use: controller.create)
            admin.get("posts", ":id", "edit", use: controller.edit)
            admin.post("posts", use: controller.store)
            admin.post("posts", ":id", "edit", use: controller.update)
            admin.post("posts", "delete", use: controller.delete)
            admin.get("posts", ":id", "preview", use: controller.showPreview)
        }

        // tags
        do {
            let controller = AdminTagController()
            admin.get("tags", use: controller.index)
            admin.get("tags", "create", use: controller.create)
            admin.get("tags", ":id", "edit", use: controller.edit)
            admin.post("tags", use: controller.store)
            admin.post("tags", ":id", "edit", use: controller.update)
            admin.post("tags", "delete", use: controller.delete)
        }

        // categories
        do {
            let controller = AdminCategoryController()
            admin.get("categories", use: controller.index)
            admin.get("categories", "create", use: controller.create)
            admin.get("categories", ":id", "edit", use: controller.edit)
            admin.post("categories", use: controller.store)
            admin.post("categories", ":id", "edit", use: controller.update)
            admin.post("categories", "delete", use: controller.delete)
        }

        // images
        do {
            let controller = AdminImageController()
            admin.get("images", use: controller.index)
            admin.get("images", ":id", "edit", use: controller.edit)
            admin.post("images", ":id", "edit", use: controller.update)
            admin.post("images", ":id", "delete", use: controller.delete)
            admin.post("images", "cleanup", use: controller.cleanup)
        }

        // themes
        do {
            let controller = AdminThemeController()
            admin.get("themes", use: controller.index)
        }

        // site
        do {
            let controller = AdminSiteInfoController()
            admin.get("siteinfo", "edit", use: controller.index)
            admin.post("siteinfo", "edit", use: controller.store)
        }

        // user
        do {
            let controller = AdminUserController()
            admin.get("user", "edit", use: controller.index)
            admin.post("user", "edit", use: controller.store)
        }
    }
}
