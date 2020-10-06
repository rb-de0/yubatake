import Vapor

final class PublicFileMiddleware: Middleware {

    private let base: FileMiddleware

    init(base: FileMiddleware) {
        self.base = base
    }

    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        if request.url.path.hasSuffix(".leaf") {
            return request.eventLoop.future(Response(status: .notFound))
        }
        return base.respond(to: request, chainingTo: next)
    }
}
