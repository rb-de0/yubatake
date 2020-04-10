import Vapor

final class LogoutController {

    func index(request: Request) throws -> Response {
        request.auth.logout(User.self)
        return request.redirect(to: "/login")
    }
}
