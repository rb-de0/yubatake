import Authentication
import Vapor

final class APIRoutes: RouteCollection {
    
    func boot(router: Router) throws {
        
        let api = router
            .grouped("api")
            .grouped(AuthErrorMiddleware<User>())
        
        // markdown
        do {
            let controller = API.HtmlController()
            api.post(ConvertedMarkdownForm.self, at: "converted_markdown", use: controller.store)
        }
        
        // images
        do {
            let controller = API.ImageController()
            api.get("images", use: controller.index)
            api.post(ImageUploadForm.self, at: "images", use: controller.store)
        }
    }
}
