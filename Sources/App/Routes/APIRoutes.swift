import Authentication
import Vapor

final class APIRoutes: RouteCollection {
    
    func boot(router: Router) throws {
        
        let api = router
            .grouped("api")
            .grouped(AuthErrorMiddleware<User>())
        
        // images
        do {
            let controller = API.ImageController()
            api.get("images", use: controller.index)
            api.post(ImageUploadForm.self, at: "images", use: controller.store)
        }
        
        // themes
        do {
            let controller = API.ThemeController()
            api.get("themes", use: controller.index)
            api.post(ThemeForm.self, at: "themes", use: controller.store)
        }
        
        // files
        do {
            let controller = API.FileController()
            api.get("themes", Theme.parameter, "files", use: controller.index)
            api.get("files", use: controller.show)
            api.post(EditableFileUpdateForm.self, at: "files", use: controller.store)
        }
    }
}
