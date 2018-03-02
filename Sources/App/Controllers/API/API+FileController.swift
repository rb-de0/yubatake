import HTTP
import Vapor

extension API {
    
    final class FileController: ResourceRepresentable {
        
        func makeResource() -> Resource<String> {
            return Resource(
                index: index
            )
        }
        
        private lazy var fileRepository = resolve(FileRepository.self)
        
        func index(request: Request) throws -> ResponseRepresentable {
            let theme = request.data["theme"]?.string
            return try fileRepository.files(in: theme).makeJSON()
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
        
        func reset(request: Request) throws -> ResponseRepresentable {
            try fileRepository.deleteAllUserFiles()
            return Response(status: .ok)
        }
    }
}
