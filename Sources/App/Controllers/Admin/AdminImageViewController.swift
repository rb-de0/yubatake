import Vapor

final class AdminImageViewController {
    
    private struct ContextMaker {
        
        static func makeIndexView() -> AdminViewContext {
            return AdminViewContext(path: "admin/images", menuType: .images)
        }
        
        static func makeCreateView() -> AdminViewContext {
            return AdminViewContext(path: "admin/edit-image", menuType: .images)
        }
    }
    
    private struct IndexContext: Encodable {
        
        private enum CodingKeys: String, CodingKey {
            case hasNotFound = "has_not_found"
        }
        
        let hasNotFound: Bool
    }
    
    func index(request: Request) throws -> Future<View> {
        
        let repository = try request.make(ImageRepository.self)
        return Image.query(on: request).all().flatMap { images in
            let publicImages = try images.map { try $0.formPublic(on: request) }
            let hasNotFound = publicImages.contains(where: { !repository.isExist(at: $0.name) })
            return try ContextMaker.makeIndexView().makeResponse(context: IndexContext(hasNotFound: hasNotFound), formDataType: ImageForm.self, for: request)
        }
    }
    
    func edit(request: Request) throws -> Future<View> {
        return try request.parameters.next(Image.self).flatMap { image in
            try ContextMaker.makeCreateView().makeResponse(context: try image.formPublic(on: request), formDataType: ImageForm.self, for: request)
        }
    }
    
    func update(request: Request, form: ImageForm) throws -> Future<Response> {
        
        let repository = try request.make(ImageRepository.self)
        
        return try request.parameters.next(Image.self).flatMap { image in
            
            let id = try image.requireID()
            let beforeName = try image.formPublic(on: request).name
            let applied = try image.apply(form: form, on: request)
            let afterName = try applied.formPublic(on: request).name
            
            let updateTransaction = request.withPooledConnection(to: .mysql) { conn in
                
                Image.Database.inTransaction(on: conn) { transaction in
                    
                    applied.save(on: transaction).map { _ in
                        try repository.rename(from: beforeName, to: afterName)
                    }
                }
            }
            
            return updateTransaction
                .map {
                    request.redirect(to: "/admin/images/\(id)/edit")
                }
                .catchMap { error in
                    try request.redirect(to: "/admin/images/\(id)/edit", with: FormError(error: error, formData: form))
                }
        }
    }
    
    func delete(request: Request) throws -> Future<Response> {
        
        let repository = try request.make(ImageRepository.self)
        
        return try request.parameters.next(Image.self).flatMap { image in
            
            let deleteTransaction = request.withPooledConnection(to: .mysql) { conn in
                
                Image.Database.inTransaction(on: conn) { transaction in
                    
                    image.delete(on: transaction).map { _ in
                        try repository.delete(at: try image.formPublic(on: request).name)
                    }
                }
            }
            
            return deleteTransaction.map {
                request.redirect(to: "/admin/images")
            }
        }
    }
    
    func cleanup(request: Request) throws -> Future<Response> {
        
        let repository = try request.make(ImageRepository.self)
        
        return Image.query(on: request).all().flatMap { images in
            let notFoundImages = try images.map { try $0.formPublic(on: request) }
                .filter { !repository.isExist(at: $0.name) }
                .map { $0.image }
            let deleteImages = notFoundImages.map { $0.delete(on: request) }
            return Future<Void>.andAll(deleteImages, eventLoop: request.eventLoop).map {
                request.redirect(to: "/admin/images")
            }
        }
    }
}
