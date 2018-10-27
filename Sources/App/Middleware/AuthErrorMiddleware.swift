import Authentication
import Vapor

final class AuthErrorMiddleware<A>: Middleware, Service where A: Authenticatable {
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        if try request.isAuthenticated(A.self) {
            return try next.respond(to: request)
        }
        
        let response = request.response()
        response.http.status = .forbidden
        return Future.map(on: request) { response }
    }
}
