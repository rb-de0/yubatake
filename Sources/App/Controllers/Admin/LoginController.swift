import Authentication
import Vapor

final class LoginController {
    
    func index(request: Request) throws -> Future<View> {
        return try AdminViewContext(path: "login", title: "Login").makeResponse(for: request)
    }

    func store(request: Request, form: LoginForm) throws -> Future<Response> {
        
        let verifier = try request.make(PasswordVerifier.self)
        
        return User.authenticate(username: form.name, password: form.password, using: verifier, on: request)
            .unwrap(or: Abort(.unauthorized))
            .map { user -> Response in
                try request.authenticate(user)
                return request.redirect(to: "admin/posts")
            }
            .catchMap { error in
                return try request.redirect(to: "login", with: error.localizedDescription)
            }
    }
}
