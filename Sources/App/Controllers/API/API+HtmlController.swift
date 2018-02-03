import HTTP
import Vapor

extension API {
    
    final class HtmlController: ResourceRepresentable {
        
        func makeResource() -> Resource<String> {
            return Resource(store: store)
        }
        
        func store(request: Request) throws -> ResponseRepresentable {
            let html = try Html(request: request)
            return try html.makeJSON()
        }
    }
}
