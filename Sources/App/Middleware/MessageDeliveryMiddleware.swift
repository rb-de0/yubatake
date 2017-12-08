import Vapor

final class MessageDeliveryMiddleware: Middleware {
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        
        guard let session = request.session, let errorMessage = session.data["error_message"] else {
            return try next.respond(to: request)
        }
        
        request.storage["error_message"] = errorMessage
        session.data.removeKey("error_message")
        
        return try next.respond(to: request)
    }
}
