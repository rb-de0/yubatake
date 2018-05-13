import Vapor

final class AdminSiteInfoController {
    
    private struct ContextMaker {
        
        static func makeCreateView() -> AdminViewContext {
            return AdminViewContext(path: "edit-siteInfo", menuType: .siteInfo)
        }
    }
    
    func index(request: Request) throws -> Future<View> {
        return try SiteInfo.shared(on: request).flatMap { siteInfo in
            return try ContextMaker.makeCreateView().makeResponse(context: siteInfo, formDataType: SiteInfoForm.self, for: request)
        }
    }
    
    func store(request: Request, form: SiteInfoForm) throws -> Future<Response> {
        return try SiteInfo.shared(on: request).flatMap { siteInfo in
            try siteInfo.apply(form: form).save(on: request).transform(to: ())
        }
        .map {
            return request.redirect(to: "/admin/siteinfo/edit")
        }
        .catchMap { error in
            return try request.redirect(to: "/admin/siteinfo/edit", with: FormError(error: error, formData: form))
        }
    }
}
