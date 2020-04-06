import Vapor

final class AdminSiteInfoController {

    private struct ContextMaker {
        static func makeCreateView() -> AdminViewContext {
            return AdminViewContext(path: "edit-siteInfo", menuType: .siteInfo)
        }
    }

    func index(request: Request) throws -> EventLoopFuture<View> {
        return SiteInfo.shared(on: request.db)
            .flatMap { siteInfo in
                do {
                    return try ContextMaker.makeCreateView().makeResponse(context: siteInfo, formDataType: SiteInfoForm.self, for: request)
                } catch {
                    return request.eventLoop.future(error: error)
                }
            }
    }

    func store(request: Request) throws -> EventLoopFuture<Response> {
        try SiteInfoForm.validate(request)
        let form = try request.content.decode(SiteInfoForm.self)
        return SiteInfo.shared(on: request.db)
            .flatMap { siteInfo in
                siteInfo.apply(form: form)
                return siteInfo.save(on: request.db)
            }
            .map {
                request.redirect(to: "/admin/siteinfo/edit")
            }
            .flatMapErrorThrowing { error in
                try request.redirect(to: "/admin/siteinfo/edit", with: FormError(error: error, formData: form))
            }
    }
}
