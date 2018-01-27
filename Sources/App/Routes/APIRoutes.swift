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
    }
}
