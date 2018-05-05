import Vapor

final class PublicRoutes: RouteCollection {
    
    func boot(router: Router) throws {
        
        // posts
        do {
            let controller = PostController()
            router.get("", use: controller.index)
            router.get("posts", use: controller.index)
            router.get("tags", Tag.parameter, "posts", use: controller.indexInTag)
            router.get("categories", Category.parameter, "posts", use: controller.indexInCategory)
            router.get("categories/noncategorized/posts", use: controller.indexNoCategory)
            
            router.get(Post.parameter, use: controller.show)
            router.get("posts", Post.parameter, use: controller.show)
        }
    }
}
