import Vapor

final class AdminUserController {
    
    private struct ContextMaker {
        
        static func makeCreateView() -> AdminViewContext {
            return AdminViewContext(path: "admin/edit-user", menuType: .userSettings)
        }
    }
    
    func index(request: Request) throws -> Future<View> {
        let user = try request.requireAuthenticated(User.self).formPublic()
        return try ContextMaker.makeCreateView().makeResponse(context: user, formDataType: UserForm.self, for: request)
    }
    
    func store(request: Request, form: UserForm) throws -> Future<Response> {
        let user = try request.requireAuthenticated(User.self)
        return try user.apply(form: form, on: request).flatMap { user in
            user.save(on: request).transform(to: ())
        }.map {
            request.redirect(to: "/admin/user/edit")
        }
        .catchMap { error in
            return try request.redirect(to: "/admin/user/edit", with: FormError(error: error, formData: form))
        }
    }
}
