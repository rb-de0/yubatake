import Vapor

final class PublicRoutes: RouteCollection {

    func boot(routes: RoutesBuilder) throws {

        // posts
        do {
            let controller = PostController()
            routes.get("", use: controller.index)
            routes.get("posts", use: controller.index)
            routes.get(":id", use: controller.show)
            routes.get("posts", ":id", use: controller.show)
            routes.get("tags", ":id", "posts", use: controller.indexInTag)
            routes.get("categories", ":id", "posts", use: controller.indexInCategory)
            routes.get("categories", "noncategorized", "posts", use: controller.indexNoCategory)
        }
    }
}
