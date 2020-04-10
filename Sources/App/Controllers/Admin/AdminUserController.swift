import Vapor

final class AdminUserController {

    private struct ContextMaker {
        static func makeCreateView() -> AdminViewContext {
            return AdminViewContext(path: "edit-user", menuType: .userSettings)
        }
    }

    func index(request: Request) throws -> EventLoopFuture<View> {
        let user = try request.auth.require(User.self).formPublic()
        return try ContextMaker.makeCreateView().makeResponse(context: user, formDataType: UserForm.self, for: request)
    }

    func store(request: Request) throws -> EventLoopFuture<Response> {
        let form = try request.content.decode(UserForm.self)
        let user = try request.auth.require(User.self)
        do {
            try UserForm.validate(request)
        } catch {
            let response = try request.redirect(to: "/admin/user/edit", with: FormError(error: error, formData: form))
            return request.eventLoop.future(response)
        }
        return user.apply(form: form, on: request)
            .flatMap {
                user.save(on: request.db)
            }
            .map {
                request.redirect(to: "/admin/user/edit")
            }
            .flatMapErrorThrowing { error in
                try request.redirect(to: "/admin/user/edit", with: FormError(error: error, formData: form))
            }
    }
}
