import Vapor

final class LoginController {

    func index(request: Request) throws -> EventLoopFuture<View> {
        return try AdminViewContext(path: "login", title: "Login").makeResponse(for: request)
    }

    func store(request: Request) throws -> EventLoopFuture<Response> {
        let form = try request.content.decode(LoginForm.self)
        return User.authenticate(username: form.name, password: form.password, on: request)
            .map { user -> Response in
                request.auth.login(user)
                return request.redirect(to: "/admin/posts")
            }
            .flatMapErrorThrowing { _ in
                request.redirect(to: "/login")
            }
    }
}
