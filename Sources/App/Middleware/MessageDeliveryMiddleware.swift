import HTTP
import Vapor

final class MessageDeliveryMiddleware: Middleware {
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        
        guard let session = request.session else {
            return try next.respond(to: request)
        }
        
        if let errorMessage = session.data["error_message"] {
            request.storage["error_message"] = errorMessage
            session.data.removeKey("error_message")
        }
        
        let formDataKey = NoDerivery.formDataKey
        
        if let formData = session.data[formDataKey] {
            request.storage[formDataKey] = formData
            session.data.removeKey(formDataKey)
        }
        
        return try next.respond(to: request)
    }
}

extension Response {
    
    convenience init(redirect location: String, with error: FormError, for request: Request) {
        
        if let session = request.session {
            try? session.data.set("error_message", error.errorMessage)
            if let formData = request.formURLEncoded {
                try? error.deliverer.stash(on: session, formData: formData)
            }
        }
        
        self.init(redirect: location)
    }
}
