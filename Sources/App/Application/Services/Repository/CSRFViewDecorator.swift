import CSRF
import Vapor

final class CSRFViewDecorator: ViewDecorator {
    func decodate(context: Encodable, for request: Request) -> Encodable {
        let token = CSRF().createToken(from: request)
        return context.add("csrfToken", token)
    }
}
