import Vapor
import AuthProvider

final class APIRoutes: RouteCollection, EmptyInitializable {
    
    func build(_ builder: RouteBuilder) throws {
        
        let api = builder
            .grouped([
                PersistMiddleware<User>(),
                PasswordAuthenticationMiddleware<User>()]
            )
            .grouped("api")
        
        // markdown
        api.resource("converted_markdown", API.HtmlController())
        
        // files
        api.resource("files", API.FileController())
        api.post("files/reset", handler: API.FileController().reset)
        api.get("filebody", handler: API.FileController().show)
        api.post("filebody", handler: API.FileController().store)
        api.post("filebody/delete", handler: API.FileController().destroy)
        
        // images
        api.resource("images", API.ImageController())
        
        // themes
        api.resource("themes", API.ThemeController())
        api.post("themes/apply", handler: API.ThemeController().apply)
        api.post("themes/delete", handler: API.ThemeController().destroy)
    }
}
