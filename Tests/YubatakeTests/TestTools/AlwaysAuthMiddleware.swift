@testable import App
import Vapor

enum TestError: Error {
    case unexpected
}

final class AlwaysAuthMiddleware: Middleware, Service {
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        return User.find(1, on: request).unwrap(or: TestError.unexpected).flatMap(to: Response.self) { user in
            try request.authenticate(user)
            return try next.respond(to: request)
        }
    }
}
