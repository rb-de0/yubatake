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
            
            guard let imageExtension = form.name.split(separator: ".").last else {
                return request.future(HTTPStatus.badRequest)
            }
            
            let repository = try request.make(ImageRepository.self)
            let imageName = try request.make(ImageNameGenerator.self).generateImageName(from: form.name)
            let imageFileName = imageName.appending(".").appending(imageExtension)
            let newImage = try Image(from: imageFileName, on: request)
            
            let deleteTransaction = request.withPooledConnection(to: .mysql) { conn in
                
                MySQLDatabase.transactionExecute({ transaction in
                    newImage.save(on: transaction).map { _ in
                        try repository.save(image: form.data, for: imageFileName)
                    }
                }, on: conn)
            }
            
            return deleteTransaction.transform(to: .ok)
        }
    }
}
