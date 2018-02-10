import HTTP
import Vapor

final class AdminFileController: ResourceRepresentable {
    
    struct ContextMaker {
        
        static func makeCreateView() -> AdminViewContext {
            return AdminViewContext(path: "admin/files", menuType: .editFile)
        }
    }
    
    func makeResource() -> Resource<String> {
        return Resource(index: index)
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try ContextMaker.makeCreateView().makeResponse(for: request)
    }
}
