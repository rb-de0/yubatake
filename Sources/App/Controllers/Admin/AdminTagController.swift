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
    
    func index(request: Request) throws -> Future<View> {
        return try Tag.query(on: request).paginate(for: request).flatMap { page in
            try ContextMaker.makeIndexView().makeResponse(context: page.response(), for: request)
        }
    }
    
    func create(request: Request) throws -> Future<View> {
        return try ContextMaker.makeCreateView().makeResponse(formDataType: TagForm.self, for: request)
    }
    
    func edit(request: Request) throws -> Future<View> {
        return try request.parameters.next(Tag.self).flatMap { tag in
            try ContextMaker.makeCreateView().makeResponse(context: tag, formDataType: TagForm.self, for: request)
        }
    }
    
    func store(request: Request, form: TagForm) throws -> Future<Response> {
        
        return Future.flatMap(on: request) {
            try Tag(from: form).save(on: request).map { tag in
                let id = try tag.requireID()
                return request.redirect(to: "/admin/tags/\(id)/edit")
            }
        }
        .catchMap { error in
            return try request.redirect(to: "/admin/tags/create", with: FormError(error: error, formData: form))
        }
    }
    
    func update(request: Request, form: TagForm) throws -> Future<Response> {
        let existingTag = try request.parameters.next(Tag.self)
        
        return existingTag.flatMap { tag in
            let id = try tag.requireID()
            return Future.flatMap(on: request) {
                try tag.apply(form: form).save(on: request).map { _ in
                    request.redirect(to: "/admin/tags/\(id)/edit")
                }
            }
            .catchMap { error in
                return try request.redirect(to: "/admin/tags/\(id)/edit", with: FormError(error: error, formData: form))
            }
        }
    }
    
    func delete(request: Request, form: DeleteTagsForm) throws -> Future<Response> {
        
        let ids = form.tags ?? []
        let eventLoop = request.eventLoop
        let deleteTags = ids.map {
            Tag.find($0, on: request)
                .unwrap(or: Abort(.badRequest))
                .delete(on: request)
                .transform(to: ())
        }
        
        return Future<Void>.andAll(deleteTags, eventLoop: eventLoop)
            .map {
                request.redirect(to: "/admin/tags")
            }
    }
}
