import Vapor

final class PublicFileMiddleware: Middleware, Service {
    
    private let base: FileMiddleware
    
    init(base: FileMiddleware) {
        self.base = base
    }
    
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        
        if request.http.url.path.hasSuffix(".leaf") {
            throw Abort(.notFound)
        }
        
        return try base.respond(to: request, chainingTo: next)
    }
}
