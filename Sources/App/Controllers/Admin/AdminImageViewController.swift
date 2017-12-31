import Crypto
import HTTP
import Vapor

final class AdminImageViewController: EditableResourceRepresentable {
    
    struct ContextMaker {
        
        static func makeIndexView() -> AdminViewContext {
            return AdminViewContext(path: "admin/images", menuType: .images)
        }
        
        static func makeCreateView() -> AdminViewContext {
            return AdminViewContext(path: "admin/edit-image", menuType: .images)
        }
    }
    
    func makeResource() -> EditableResource<Image> {
        
        let resource = Resource<Image>(
            index: index,
            store: store,
            edit: edit
        )
        
        return EditableResource(
            resource: resource,
            update: update,
            destroy: destroy,
            destroyKey: "images"
        )
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        let page = try Image.makeQuery().paginate(for: request).makeJSON()
        return try ContextMaker.makeIndexView().makeResponse(context: page, for: request)
    }
    
    func store(request: Request) throws -> ResponseRepresentable {
        
        let imageData = try ImageData(request: request)
        let image = try Image(data: imageData)

        try Image.database?.transaction { conn in
            try image.makeQuery(conn).save()
            try imageData.save()
        }

        return Response(redirect: "/admin/images")
    }
    
    func edit(request: Request, image: Image) throws -> ResponseRepresentable {
        return try ContextMaker.makeCreateView().makeResponse(context: image.makeJSON(), for: request)
    }
    
    func update(request: Request, image: Image) throws -> ResponseRepresentable {
        
        guard let id = image.id?.int else {
            throw Abort.serverError
        }
        
        do {
            
            try image.update(for: request)
            try image.save()
            
            return Response(redirect: "/admin/images/\(id)/edit")
            
        } catch {
            
            return Response(redirect: "/admin/images/\(id)/edit", withError: error, for: request)
        }
    }
    
    func destroy(request: Request, images: [Image]) throws -> ResponseRepresentable {
        
        try Image.database?.transaction { conn in
            
            try images.forEach {
                try $0.makeQuery(conn).delete()
                try $0.deleteImageData()
            }
        }

        return Response(redirect: "/admin/images")
    }
}
