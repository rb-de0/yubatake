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
        
        api.resource("converted_markdown", API.HtmlController())
        api.resource("files", API.FileController())
        api.get("filebody", handler: API.FileController().show)
        api.post("filebody", handler: API.FileController().store)
    }
}
