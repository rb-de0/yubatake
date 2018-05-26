import Vapor
import Fluent

fileprivate struct MessageDeliveryMiddlewareConst {
    static let errorMessageKey = "error_message"
}

struct MessageDeliveryViewDecorator: ViewDecorator {
    
    func decorate(context: inout [String : TemplateData], for request: Request) throws {
        
        guard let errorMessage = try request.session()[MessageDeliveryMiddlewareConst.errorMessageKey] else {
            return
        }
        
        context[MessageDeliveryMiddlewareConst.errorMessageKey] = .string(errorMessage)
    }
}

final class MessageDeliveryMiddleware: Middleware, Service {

    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        
        let promise = request.eventLoop.newPromise(Response.self)
        let session = try request.session()
        let hasErrorMessage = session[MessageDeliveryMiddlewareConst.errorMessageKey] != nil
        
        func processAfterRequest() {
            
            if hasErrorMessage {
                session[MessageDeliveryMiddlewareConst.errorMessageKey] = nil
            }
        }
        
        try next.respond(to: request)
            .map { res in
                processAfterRequest()
                return res
            }
            .do { res in
                promise.succeed(result: res)
            }
            .catch { error in
                promise.fail(error: error)
            }
        
        return promise.futureResult
    }
}

extension Request {
    
    func redirect(to location: String, with errorMessage: String) throws -> Response {
        try session()[MessageDeliveryMiddlewareConst.errorMessageKey] = errorMessage
        return redirect(to: location)
    }
}
