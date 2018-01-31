import HTTP
import Vapor

final class UserFileMiddleware: Middleware {
    
    private var userPublicDir: String
    private let chunkSize = 32_768
    
    public init(userPublicDir: String) {
        self.userPublicDir = userPublicDir.finished(with: "/")
    }
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        do {
            return try next.respond(to: request)
        } catch RouterError.missingRoute {
            var path = request.uri.path
            guard !path.contains("../") else { throw HTTP.Status.forbidden }
            if path.hasPrefix("/") {
                path = String(path.dropFirst())
            }
            let filePath = userPublicDir + path
            let ifNoneMatch = request.headers["If-None-Match"]
            
            do {
                let response = try Response(filePath: filePath, ifNoneMatch: ifNoneMatch, chunkSize: chunkSize)
                return response
            } catch let error as Abort where error.status == .notFound {
                throw RouterError.missingRoute(for: request)
            }
        }
    }
}

