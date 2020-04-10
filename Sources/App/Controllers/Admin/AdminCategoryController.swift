import Fluent
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

    func index(request: Request) throws -> EventLoopFuture<View> {
        return Category.query(on: request.db).withRelated()
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
        return try ContextMaker.makeCreateView().makeResponse(formDataType: CategoryForm.self, for: request)
    }

    func edit(request: Request) throws -> EventLoopFuture<View> {
        guard let categoryId = request.parameters.get("id", as: Int.self) else {
            throw Abort(.notFound)
        }
        return Category.query(on: request.db).filter(\.$id == categoryId).withRelated()
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { category in
                do {
                    return try ContextMaker.makeCreateView().makeResponse(context: category, formDataType: CategoryForm.self, for: request)
                } catch {
                    return request.eventLoop.future(error: error)
                }
            }
    }

    func store(request: Request) throws -> EventLoopFuture<Response> {
        let form = try request.content.decode(CategoryForm.self)
        let category = Category(form: form)
        do {
            try CategoryForm.validate(request)
        } catch {
            let resposne = try request.redirect(to: "/admin/categories/create", with: FormError(error: error, formData: form))
            return request.eventLoop.future(resposne)
        }
        return category.save(on: request.db)
            .flatMapThrowing { _ -> Response in
                let id = try category.requireID()
                return request.redirect(to: "/admin/categories/\(id)/edit")
            }
            .flatMapErrorThrowing { error in
                try request.redirect(to: "/admin/categories/create", with: FormError(error: error, formData: form))
            }
    }

    func update(request: Request) throws -> EventLoopFuture<Response> {
        guard let categoryId = request.parameters.get("id", as: Int.self) else {
            throw Abort(.notFound)
        }
        let form = try request.content.decode(CategoryForm.self)
        return Category.query(on: request.db).filter(\.$id == categoryId).withRelated()
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { category in
                do {
                    try CategoryForm.validate(request)
                    category.apply(form: form)
                    return category.save(on: request.db)
                } catch {
                    return request.eventLoop.future(error: error)
                }
            }
            .map {
                request.redirect(to: "/admin/categories/\(categoryId)/edit")
            }
            .flatMapErrorThrowing { error in
                try request.redirect(to: "/admin/categories/\(categoryId)/edit", with: FormError(error: error, formData: form))
            }
    }

    func delete(request: Request) throws -> EventLoopFuture<Response> {
        let form = try request.content.decode(DeleteCategoriesForm.self)
        let ids = form.categories
        return Category.query(on: request.db).filter(\.$id ~~ ids)
            .delete()
            .map {
                request.redirect(to: "/admin/categories")
            }
    }
}
