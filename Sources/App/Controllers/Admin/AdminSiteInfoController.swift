import HTTP
import Vapor
import Validation

final class AdminSiteInfoController: ResourceRepresentable {
    
    struct ContextMaker {
        
        static func makeCreateView() -> AdminViewContext {
            return AdminViewContext(path: "admin/new-siteInfo", menuType: .siteInfo)
        }
    }
    
    func makeResource() -> Resource<SiteInfo> {
        return Resource(index: index, store: store)
    }

    func index(request: Request) throws -> ResponseRepresentable {
        
        guard let siteInfo = try SiteInfo.shared() else {
            return try ContextMaker.makeCreateView().makeResponse(for: request)
        }
        
        return try ContextMaker.makeCreateView().makeResponse(context: siteInfo.makeJSON(), for: request)
    }
    
    func store(request: Request) throws -> ResponseRepresentable {
        
        do {
            
            let siteInfo = try SiteInfo.shared() ?? SiteInfo(request: request)
        
            try siteInfo.update(for: request)
            try siteInfo.save()
            
            return Response(redirect: "/admin/siteinfo/edit")
            
        } catch {
            
            return Response(redirect: "/admin/siteinfo/edit", withError: error, for: request)
        }
    }
}


