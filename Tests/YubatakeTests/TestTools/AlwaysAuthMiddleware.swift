@testable import App
import Vapor

enum TestError: Error {
    case unexpected
}

final class AlwaysAuthMiddleware: Middleware {
    
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        return User.find(1, on: request.db).unwrap(or: TestError.unexpected).flatMap { user in
            request.auth.login(user)
            return next.respond(to: request)
        }
    }
}
