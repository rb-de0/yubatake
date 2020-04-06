import Vapor

private struct MessageDeliveryMiddlewareConst {
    static let errorMessageKey = "errorMessage"
}

struct MessageDeliveryViewDecorator: ViewDecorator {
    func decodate(context: Encodable, for request: Request) -> Encodable {
        guard let errorMessage = request.session.data[MessageDeliveryMiddlewareConst.errorMessageKey] else {
            return context
        }
        return context.add(MessageDeliveryMiddlewareConst.errorMessageKey, errorMessage)
    }
}

final class MessageDeliveryMiddleware: Middleware {

    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        let hasErrorMessage = request.session.data[MessageDeliveryMiddlewareConst.errorMessageKey] != nil
        func processAfterRequest() {
            if hasErrorMessage {
                request.session.data[MessageDeliveryMiddlewareConst.errorMessageKey] = nil
            }
        }
        return next.respond(to: request)
            .map { response -> Response in
                processAfterRequest()
                return response
            }
    }
}

extension Request {

    func redirect(to location: String, with errorMessage: String) throws -> Response {
        session.data[MessageDeliveryMiddlewareConst.errorMessageKey] = errorMessage
        return redirect(to: location)
    }
}
