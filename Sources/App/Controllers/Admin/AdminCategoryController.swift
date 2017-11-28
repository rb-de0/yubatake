import HTTP

final class AdminCategoryController: EditableResourceRepresentable {
    
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
        return try AdminViewContext(menuType: .categories).formView("admin/categories", context: page, for: request)
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        return try AdminViewContext(menuType: .categories).formView("admin/new-category", for: request)
    }
    
    func store(request: Request) throws -> ResponseRepresentable {
        let category = Category(request: request)
        try category.save()
        
        guard let id = category.id?.int else {
            throw Abort.serverError
        }
        
        return Response(redirect: "/admin/categories/\(id)/edit")
    }
    
    func edit(request: Request, category: Category) throws -> ResponseRepresentable {
        return try AdminViewContext(menuType: .categories).formView("admin/new-category", context: category.makeJSON(), for: request)
    }
    
    func update(request: Request, category: Category) throws -> ResponseRepresentable {
        try category.update(for: request)
        try category.save()
        
        guard let id = category.id?.int else {
            throw Abort.serverError
        }
        
        return Response(redirect: "/admin/categories/\(id)/edit")
    }
    
    func destroy(request: Request, categories: [Category]) throws -> ResponseRepresentable {
        
        try categories.forEach {
            try $0.delete()
        }
        
        return Response(redirect: "/admin/categories")
    }
}


