import Vapor

final class AdminCategoryController {
    
    private struct ContextMaker {
        
        static func makeIndexView() -> AdminViewContext {
            return AdminViewContext(path: "categories", menuType: .categories)
        }
        
        static func makeCreateView() -> AdminViewContext {
            return AdminViewContext(path: "new-category", menuType: .categories)
        }
    }
    
    func index(request: Request) throws -> Future<View> {
        return try Category.query(on: request).paginate(for: request).flatMap { page in
            try ContextMaker.makeIndexView().makeResponse(context: page.response(), for: request)
        }
    }
    
    func create(request: Request) throws -> Future<View> {
        return try ContextMaker.makeCreateView().makeResponse(formDataType: CategoryForm.self, for: request)
    }
    
    func edit(request: Request) throws -> Future<View> {
        
        return try request.parameters.next(Category.self).flatMap { category in
            try ContextMaker.makeCreateView().makeResponse(context: category, formDataType: CategoryForm.self, for: request)
        }
    }
    
    func store(request: Request, form: CategoryForm) throws -> Future<Response> {
        
        return Future.flatMap(on: request) {
            try Category(from: form).save(on: request).map { category in
                let id = try category.requireID()
                return request.redirect(to: "/admin/categories/\(id)/edit")
            }
        }
        .catchMap { error in
            return try request.redirect(to: "/admin/categories/create", with: FormError(error: error, formData: form))
        }
    }
    
    func update(request: Request, form: CategoryForm) throws -> Future<Response> {
        let existingCategory = try request.parameters.next(Category.self)
        
        return existingCategory.flatMap { category in
            let id = try category.requireID()
            return Future.flatMap(on: request) {
                try category.apply(form: form).save(on: request).map { _ in
                    request.redirect(to: "/admin/categories/\(id)/edit")
                }
            }
            .catchMap { error in
                return try request.redirect(to: "/admin/categories/\(id)/edit", with: FormError(error: error, formData: form))
            }
        }
    }
    
    func delete(request: Request, form: DeleteCategoriesForm) throws -> Future<Response> {
        
        let ids = form.categories ?? []
        let eventLoop = request.eventLoop
        let deleteCategories = try ids.map {
            try Category.find($0, on: request)
                .unwrap(or: Abort(.badRequest))
                .delete(on: request)
                .transform(to: ())
        }
        
        return Future<Void>.andAll(deleteCategories, eventLoop: eventLoop)
            .map {
                request.redirect(to: "/admin/categories")
            }
    }
}
