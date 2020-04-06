import Vapor

final class AuthErrorMiddleware<A>: Middleware where A: Authenticatable {
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        if request.auth.has(A.self) {
            return next.respond(to: request)
        }
        return request.eventLoop.future(Response(status: .forbidden))
    }
}
