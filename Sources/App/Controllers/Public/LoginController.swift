import AuthProvider
import HTTP
import Vapor

final class LoginController: ResourceRepresentable {
    
    func makeResource() -> Resource<String> {
        return Resource(
            index: index,
            store: store
        )
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try PublicViewContext(path: "public/login", title: "Login").makeResponse(for: request)
    }
    
    func store(request: Request) throws -> ResponseRepresentable {
        
        do {
            
            let credential = try request.userNamePassword()
            let user = try User.authenticate(credential)
            try user.persist(for: request)
            
            return Response(redirect: "admin/posts")
            
        } catch {
            
            return Response(redirect: "login", with: FormError(error: error), for: request)
        }
    }
}
