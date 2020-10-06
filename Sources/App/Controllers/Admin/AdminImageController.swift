import Fluent
import Vapor

final class AdminImageController {

    private struct ContextMaker {
        static func makeIndexView() -> AdminViewContext {
            return AdminViewContext(path: "images", menuType: .images)
        }

        static func makeCreateView() -> AdminViewContext {
            return AdminViewContext(path: "edit-image", menuType: .images)
        }
    }

    private struct IndexContext: Encodable {
        private enum CodingKeys: String, CodingKey {
            case hasNotFound
        }

        let hasNotFound: Bool
    }

    func index(request: Request) throws -> EventLoopFuture<View> {
        let repository = request.application.imageRepository
        return Image.query(on: request.db).all()
            .flatMap { images in
                let publicImages = images.map { $0.formPublic(on: request.application) }
                let hasNotFound = publicImages.contains(where: { !repository.isExist(at: $0.name) })
                do {
                    return try ContextMaker.makeIndexView().makeResponse(context: IndexContext(hasNotFound: hasNotFound), formDataType: ImageForm.self, for: request)
                } catch {
                    return request.eventLoop.future(error: error)
                }
            }
    }

    func edit(request: Request) throws -> EventLoopFuture<View> {
        guard let imageId = request.parameters.get("id", as: Int.self) else {
            throw Abort(.notFound)
        }
        return Image.find(imageId, on: request.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { image in
                do {
                    let publicImage = image.formPublic(on: request.application)
                    return try ContextMaker.makeCreateView().makeResponse(context: publicImage, formDataType: ImageForm.self, for: request)
                } catch {
                    return request.eventLoop.future(error: error)
                }
            }
    }

    func update(request: Request) throws -> EventLoopFuture<Response> {
        guard let imageId = request.parameters.get("id", as: Int.self) else {
            throw Abort(.notFound)
        }
        let form = try request.content.decode(ImageForm.self)
        let repository = request.application.imageRepository
        return Image.find(imageId, on: request.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { image -> EventLoopFuture<Void> in
                let beforeName = image.formPublic(on: request.application).name
                image.apply(form: form, on: request.application)
                let afterName = image.formPublic(on: request.application).name
                return request.db.transaction { tx in
                    image.save(on: tx)
                        .flatMapThrowing {
                            try repository.rename(from: beforeName, to: afterName)
                        }
                }
            }
            .map {
                request.redirect(to: "/admin/images/\(imageId)/edit")
            }

            .flatMapErrorThrowing { error in
                try request.redirect(to: "/admin/images/\(imageId)/edit", with: FormError(error: error, formData: form))
            }
    }

    func delete(request: Request) throws -> EventLoopFuture<Response> {
        guard let imageId = request.parameters.get("id", as: Int.self) else {
            throw Abort(.notFound)
        }
        let repository = request.application.imageRepository
        return Image.find(imageId, on: request.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { image -> EventLoopFuture<Void> in
                let name = image.formPublic(on: request.application).name
                return request.db.transaction { tx -> EventLoopFuture<Void> in
                    image.delete(on: tx)
                        .flatMapThrowing {
                            try repository.delete(at: name)
                        }
                }
            }
            .map {
                request.redirect(to: "/admin/images")
            }
    }

    func cleanup(request: Request) throws -> EventLoopFuture<Response> {
        let repository = request.application.imageRepository
        return Image.query(on: request.db).all()
            .flatMap { images -> EventLoopFuture<Response> in
                let notFoundImages = images.map { $0.formPublic(on: request.application) }
                    .filter { !repository.isExist(at: $0.name) }
                    .map { $0.image }
                let deleteImages = notFoundImages.map { $0.delete(on: request.db) }
                return EventLoopFuture<Void>.andAllSucceed(deleteImages, on: request.eventLoop)
                    .map {
                        request.redirect(to: "/admin/images")
                    }
            }
    }
}
