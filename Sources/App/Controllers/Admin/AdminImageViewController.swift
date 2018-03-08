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
            edit: edit
        )
        
        return EditableResource(
            resource: resource,
            update: update,
            destroy: destroy,
            destroyKey: "images"
        )
    }
    
    static let hasNotFoundKey = "has_not_found"
    
    private lazy var imageRepository = resolve(ImageRepository.self)
    
    func index(request: Request) throws -> ResponseRepresentable {
        var json = JSON()
        let hasNotFound = try Image.all().filter { image in !imageRepository.isExist(at: image.path) }.count > 0
        try json.set(AdminImageViewController.hasNotFoundKey, hasNotFound)
        return try ContextMaker.makeIndexView().makeResponse(context: json, for: request)
    }
    
    func edit(request: Request, image: Image) throws -> ResponseRepresentable {
        return try ContextMaker.makeCreateView().makeResponse(context: image.makeJSON(), for: request)
    }
    
    func update(request: Request, image: Image) throws -> ResponseRepresentable {

        let id = try image.assertId()
        
        do {
            
            let beforePath = image.path
            
            try Image.database?.transaction { conn in
                try image.update(for: request)
                try image.makeQuery(conn).save()
                try imageRepository.renameImage(at: beforePath, to: image.path)
            }
            
            return Response(redirect: "/admin/images/\(id)/edit")
            
        } catch {
            
            return Response(redirect: "/admin/images/\(id)/edit", with: FormError(error: error), for: request)
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
    
    func cleanup(request: Request) throws -> ResponseRepresentable {
        
        try Image.all()
            .filter { image in !imageRepository.isExist(at: image.path) }
            .forEach { try $0.delete() }
        
        return Response(redirect: "/admin/images")
    }
}
