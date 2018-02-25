import HTTP
import Validation

final class AdminCategoryController: EditableResourceRepresentable {
    
    struct ContextMaker {
        
        static func makeIndexView() -> AdminViewContext {
            return AdminViewContext(path: "admin/categories", menuType: .categories)
        }
        
        static func makeCreateView() -> AdminViewContext {
            return AdminViewContext(path: "admin/new-category", menuType: .categories, formDataDeliverer: Category.self)
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
            let id = try category.assertId()
        
            return Response(redirect: "/admin/categories/\(id)/edit")

        } catch {

            return Response(redirect: "/admin/categories/create", with: FormError(error: error, deliverer: Category.self), for: request)
        }
    }
    
    func edit(request: Request, category: Category) throws -> ResponseRepresentable {
        return try ContextMaker.makeCreateView().makeResponse(context: category.makeJSON(), for: request)
    }
    
    func update(request: Request, category: Category) throws -> ResponseRepresentable {
        
        let id = try category.assertId()
        
        do {
            try category.update(for: request)
            try category.save()
            
            return Response(redirect: "/admin/categories/\(id)/edit")
            
        } catch {
            
            return Response(redirect: "/admin/categories/\(id)/edit", with: FormError(error: error, deliverer: Category.self), for: request)
        }
        
    }
    
    func destroy(request: Request, categories: [Category]) throws -> ResponseRepresentable {
        
        try categories.forEach {
            try $0.delete()
        }
        
        return Response(redirect: "/admin/categories")
    }
}


