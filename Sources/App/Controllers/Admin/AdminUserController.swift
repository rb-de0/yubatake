import HTTP
import Validation
import Vapor

final class AdminUserController: ResourceRepresentable {
    
    struct ContextMaker {
        
        static func makeCreateView() -> AdminViewContext {
            return AdminViewContext(path: "admin/edit-user", menuType: .userSettings, formDataDeliverer: User.self)
        }
    }
    
    func makeResource() -> Resource<User> {
        return Resource(index: index, store: store)
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        let user = try request.auth.assertAuthenticated(User.self)
        return try ContextMaker.makeCreateView().makeResponse(context: user.makeJSON(), for: request)
    }
    
    func store(request: Request) throws -> ResponseRepresentable {
    
        let user = try request.auth.assertAuthenticated(User.self)
        
        do {

            try user.update(for: request)
            try user.save()
            
            return Response(redirect: "/admin/user/edit")
            
        } catch {
            
            return Response(redirect: "/admin/user/edit", with: FormError(error: error, deliverer: User.self), for: request)
        }
    }
}


