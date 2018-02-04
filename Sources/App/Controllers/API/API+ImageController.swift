import HTTP
import Vapor

extension API {
    
    final class ImageController: ResourceRepresentable {
        
        func makeResource() -> Resource<Image> {
            return Resource(index: index)
        }
        
        func index(request: Request) throws -> ResponseRepresentable {
            return try Image.makeQuery().paginate(for: request).makeJSON()
        }
    }
}
