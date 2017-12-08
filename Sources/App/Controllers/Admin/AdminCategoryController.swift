import HTTP
import Validation

final class AdminCategoryController: EditableResourceRepresentable {
    
    struct ContextMaker {
        
        static func makeIndexView() -> AdminViewContext {
            return AdminViewContext(path: "admin/categories", menuType: .categories)
        }
        
        static func makeCreateView() -> AdminViewContext {
            return AdminViewContext(path: "admin/new-category", menuType: .categories)
        }
    }
    
    func makeResource() -> EditableResource<Category> {
        
        let resource = Resource(
            index: index,
            create: create,
            store: store,
            edit: edit
        )
        
        return EditableResource(
            resource: resource,
            update: update,
            destroy: destroy,
            destroyKey: "categories"
        )
    }

    func index(request: Request) throws -> ResponseRepresentable {
        let page = try Category.makeQuery().paginate(for: request).makeJSON()
        return try ContextMaker.makeIndexView().makeResponse(context: page, for: request)
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        return try ContextMaker.makeCreateView().makeResponse(for: request)
    }
    
    func store(request: Request) throws -> ResponseRepresentable {
        
        do {
            
            let category = try Category(request: request)
            try category.save()
        
            guard let id = category.id?.int else {
                throw Abort.serverError
            }
        
            return Response(redirect: "/admin/categories/\(id)/edit")
            
        } catch let validationError as ValidationError {
            
            return Response(redirect: "/admin/categories/create", withErrorMessage: validationError.reason, for: request)
            
        } catch {
            
            return Response(redirect: "/admin/categories/create", withErrorMessage: error.localizedDescription, for: request)
        }
    }
    
    func edit(request: Request, category: Category) throws -> ResponseRepresentable {
        return try ContextMaker.makeCreateView().makeResponse(context: category.makeJSON(), for: request)
    }
    
    func update(request: Request, category: Category) throws -> ResponseRepresentable {
        
        guard let id = category.id?.int else {
            throw Abort.serverError
        }
        
        do {
            try category.update(for: request)
            try category.save()
            
            return Response(redirect: "/admin/categories/\(id)/edit")
            
        } catch let validationError as ValidationError {
            
            return Response(redirect: "/admin/categories/\(id)/edit", withErrorMessage: validationError.reason, for: request)
            
        } catch {
            
            return Response(redirect: "/admin/categories/\(id)/edit", withErrorMessage: error.localizedDescription, for: request)
        }
        
    }
    
    func destroy(request: Request, categories: [Category]) throws -> ResponseRepresentable {
        
        try categories.forEach {
            try $0.delete()
        }
        
        return Response(redirect: "/admin/categories")
    }
}

