import HTTP
import Vapor

extension API {
    
    final class FileController: ResourceRepresentable {
        
        func makeResource() -> Resource<String> {
            return Resource(
                index: index
            )
        }
        
        func index(request: Request) throws -> ResponseRepresentable {
            return try FileHelper.accessibleFiles().makeJSON()
        }
        
        func store(request: Request) throws -> ResponseRepresentable {
           
            guard let body = request.data["body"]?.string else {
                throw Abort(.badRequest)
            }
            
            let set = try AccessibleFileSet(request: request)
            try set.update(body: body)
            
            return Response(status: .ok)
        }
        
        func show(request: Request) throws -> ResponseRepresentable {
            let set = try AccessibleFileSet(request: request)
            return try set.makeJSON()
        }
        
        func destroy(request: Request) throws -> ResponseRepresentable {
            let set = try AccessibleFileSet(request: request)
            try set.delete()
            return Response(status: .ok)
        }
    }
}
