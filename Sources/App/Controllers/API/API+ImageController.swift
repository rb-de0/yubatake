import HTTP
import Vapor

extension API {
    
    final class ImageController: ResourceRepresentable {
        
        func makeResource() -> Resource<Image> {
            return Resource(
                index: index,
                store: store
            )
        }
        
        func index(request: Request) throws -> ResponseRepresentable {
            return try Image.makeQuery().paginate(for: request).makeJSON()
        }
        
        func store(request: Request) throws -> ResponseRepresentable {
            
            let imageData = try ImageData(request: request)
            let image = try Image(data: imageData)
            
            try Image.database?.transaction { conn in
                try image.makeQuery(conn).save()
                try imageData.save()
            }
            
            return Response(status: .ok)
        }
    }
}
