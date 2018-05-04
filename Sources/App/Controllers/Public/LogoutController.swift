import Authentication
import Vapor

final class LogoutController {
    
    func index(request: Request) throws -> Response {
        try request.unauthenticateSession(User.self)
        return request.redirect(to: "login")
    }
}
