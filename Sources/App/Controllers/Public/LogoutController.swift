import AuthProvider
import HTTP
import Vapor

final class LogoutController: ResourceRepresentable {
    
    func makeResource() -> Resource<String> {
        return Resource(
            index: index
        )
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        try request.auth.unauthenticate()
        return Response(redirect: "login")
    }
}
