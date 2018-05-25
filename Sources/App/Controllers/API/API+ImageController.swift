import MySQL
import Pagination
import Vapor

extension API {
    
    final class ImageController {
        
        func index(request: Request) throws -> Future<Paginated<ImageGroup>> {
            
            return try Image.query(on: request).paginate(for: request).map { (page: Page<Image>) in
                let publicImages = try page.data.map { try $0.formPublic(on: request) }
                let groups = try ImageGroup.make(from: publicImages, on: request)
                return try page.transform(groups).response()
            }
        }
        
        func store(request: Request, form: ImageUploadForm) throws -> Future<HTTPStatus> {
            
            let repository = try request.make(ImageRepository.self)
            let newImage = try Image(from: form, on: request)
            
            let deleteTransaction = request.withPooledConnection(to: .mysql) { conn in
                
                MySQLDatabase.inTransaction(on: conn) { transaction in
                    
                    newImage.save(on: transaction).map { _ in
                        try repository.save(image: form.data, for: form.name)
                    }
                }
            }
            
            return deleteTransaction.transform(to: .ok)
        }
    }
}
