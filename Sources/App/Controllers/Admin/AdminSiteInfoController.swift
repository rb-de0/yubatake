import HTTP
import Vapor

final class AdminSiteInfoController: ResourceRepresentable {
    
    func makeResource() -> Resource<SiteInfo> {
        return Resource(index: index, store: store)
    }

    func index(request: Request) throws -> ResponseRepresentable {
        
        guard let siteInfo = try SiteInfo.shared() else {
            return try AdminViewContext(menuType: .siteInfo).formView("admin/new-siteInfo", for: request)
        }
        
        return try AdminViewContext(menuType: .siteInfo).formView("admin/new-siteInfo", context: siteInfo.makeJSON(), for: request)
    }
    
    func store(request: Request) throws -> ResponseRepresentable {
        
        let siteInfo = try SiteInfo.shared() ?? SiteInfo(request: request)
        
        try siteInfo.update(for: request)
        try siteInfo.save()

        return Response(redirect: "/admin/siteinfo/edit")
    }
}


