import Fluent
import Vapor

extension API {

    final class ImageController {

        func index(request: Request) throws -> EventLoopFuture<PageResponse<ImageGroup>> {
            return Image.query(on: request.db).paginate(for: request)
                .map { page -> PageResponse<ImageGroup> in
                    let publicImages = page.items.map { $0.formPublic(on: request.application) }
                    let groups = ImageGroup.make(from: publicImages, on: request.application)
                    let page = Page<ImageGroup>(items: groups, metadata: page.metadata)
                    return PageResponse(page: page)
                }
        }

        func store(request: Request) throws -> EventLoopFuture<Response> {
            let form = try request.content.decode(ImageUploadForm.self)
            guard let imageExtension = form.name.split(separator: ".").last else {
                throw Abort(.badRequest)
            }
            let repository = request.application.imageRepository
            let imageNameGenerator = request.application.imageNameGenerator
            let imageName = try imageNameGenerator.generateImageName(from: form.name)
            let imageFileName = imageName.appending(".").appending(imageExtension)
            let newImage = try Image(name: imageFileName, on: request.application)
            return request.db.transaction { tx in
                newImage.save(on: tx)
                    .flatMapThrowing {
                        try repository.save(image: form.data, for: imageFileName)
                    }
            }.transform(to: Response(status: .ok))
        }
    }
}
