import Pagination
import Vapor

extension API {
    
    final class ImageController {
        
        func index(request: Request) throws -> Future<Paginated<Image.Public>> {
            
            return try Image.query(on: request).paginate(for: request).map { (page: Page<Image>) in
                let publicImages = try page.data.map { try $0.formPublic(on: request) }
                return try page.transform(publicImages).response()
            }
        }
        
        func store(request: Request, form: ImageUploadForm) throws -> Future<HTTPStatus> {
            
            let repository = try request.make(ImageRepository.self)
            let newImage = try Image(from: form, on: request)
            
            let deleteTransaction = request.withPooledConnection(to: .mysql) { conn in
                
                Image.Database.inTransaction(on: conn) { transaction in
                    
                    newImage.save(on: transaction).map { _ in
                        try repository.save(image: form.data, for: form.name)
                    }
                }
            }
            
            return deleteTransaction.transform(to: .ok)
        }
    }
}
