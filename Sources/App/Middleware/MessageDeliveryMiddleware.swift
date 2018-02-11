import HTTP
import Vapor

final class MessageDeliveryMiddleware: Middleware {
    
    static let formDataDelivererKey = "form_data_veliverer"
    
    struct MessageDeliveryViewDecorator: ViewDecorator {
        
        func decorate(node: inout Node, with request: Request) throws {
            
            guard let formDataDeliverer = request.storage[MessageDeliveryMiddleware.formDataDelivererKey] as? FormDataDeliverable.Type else {
                return
            }
            
            if let redirectFormData = (request.storage[formDataDeliverer.formDataKey] as? Node)?.object {
                try formDataDeliverer.override(node: &node, with: redirectFormData)
            }
        }
    }
    
    init(config: Config) {
        config.addViewDecorator(MessageDeliveryViewDecorator())
    }
    
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
        
        let response = try next.respond(to: request)
        
        if let error = request.storage["form_error"] as? FormError, response.status == .seeOther {
            try? session.data.set("error_message", error.errorMessage)
            if let formData = request.formURLEncoded {
                try? error.deliverer.stash(on: session, formData: formData)
            }
        }
        
        return response
    }
}

extension Response {
    
    convenience init(redirect location: String, with error: FormError, for request: Request) {
        request.storage["form_error"] = error
        self.init(redirect: location)
    }
}

extension ViewCreator {
    
    func make(_ path: String, _ context: NodeRepresentable, for request: Request, formDataDeliverer: FormDataDeliverable.Type) throws -> View {
        request.storage[MessageDeliveryMiddleware.formDataDelivererKey] = formDataDeliverer
        return try make(path, context, for: request)
    }
}
