import Fluent
import Vapor

final class AdminTagController {

    private struct ContextMaker {
        static func makeIndexView() -> AdminViewContext {
            return AdminViewContext(path: "tags", menuType: .tags)
        }

        static func makeCreateView() -> AdminViewContext {
            return AdminViewContext(path: "new-tag", menuType: .tags)
        }
    }

    func index(request: Request) throws -> EventLoopFuture<View> {
        return Tag.query(on: request.db).withRelated()
            .paginate(for: request)
            .flatMap { page in
                do {
                    let pageResponse = PageResponse(page: page)
                    return try ContextMaker.makeIndexView().makeResponse(context: pageResponse, for: request)
                } catch {
                    return request.eventLoop.future(error: error)
                }
            }
    }

    func create(request: Request) throws -> EventLoopFuture<View> {
        return try ContextMaker.makeCreateView().makeResponse(formDataType: TagForm.self, for: request)
    }

    func edit(request: Request) throws -> EventLoopFuture<View> {
        guard let tagId = request.parameters.get("id", as: Int.self) else {
            throw Abort(.notFound)
        }
        return Tag.query(on: request.db).filter(\.$id == tagId).withRelated()
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { tag in
                do {
                    return try ContextMaker.makeCreateView().makeResponse(context: tag, formDataType: TagForm.self, for: request)
                } catch {
                    return request.eventLoop.future(error: error)
                }
            }
    }

    func store(request: Request) throws -> EventLoopFuture<Response> {
        try TagForm.validate(request)
        let form = try request.content.decode(TagForm.self)
        let tag = Tag(form: form)
        return tag.save(on: request.db)
            .flatMapThrowing { _ -> Response in
                let id = try tag.requireID()
                return request.redirect(to: "/admin/tags/\(id)/edit")
            }
            .flatMapErrorThrowing { error in
                try request.redirect(to: "/admin/tags/create", with: FormError(error: error, formData: form))
            }
    }

    func update(request: Request) throws -> EventLoopFuture<Response> {
        guard let tagId = request.parameters.get("id", as: Int.self) else {
            throw Abort(.notFound)
        }
        try TagForm.validate(request)
        let form = try request.content.decode(TagForm.self)
        return Tag.query(on: request.db).filter(\.$id == tagId).withRelated()
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { tag in
                tag.apply(form: form)
                return tag.save(on: request.db)
            }
            .map {
                request.redirect(to: "/admin/tags/\(tagId)/edit")
            }
            .flatMapErrorThrowing { error in
                try request.redirect(to: "/admin/tags/\(tagId)/edit", with: FormError(error: error, formData: form))
            }
    }

    func delete(request: Request) throws -> EventLoopFuture<Response> {
        let form = try request.content.decode(DeleteTagsForm.self)
        let ids = form.tags
        return Tag.query(on: request.db).filter(\.$id ~~ ids)
            .delete()
            .map {
                request.redirect(to: "/admin/tags")
            }
    }
}
