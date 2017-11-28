import HTTP

final class AdminTagController: EditableResourceRepresentable {
    
    func makeResource() -> EditableResource<Tag> {
        
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
            destroyKey: "tags"
        )
    }

    func index(request: Request) throws -> ResponseRepresentable {
        let page = try Tag.makeQuery().paginate(for: request).makeJSON()
        return try AdminViewContext(menuType: .tags).formView("admin/tags", context: page, for: request)
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        return try AdminViewContext(menuType: .tags).formView("admin/new-tag", for: request)
    }
    
    func store(request: Request) throws -> ResponseRepresentable {
        let tag = Tag(request: request)
        try tag.save()
        
        guard let id = tag.id?.int else {
            throw Abort.serverError
        }
        
        return Response(redirect: "/admin/tags/\(id)/edit")
    }
    
    func edit(request: Request, tag: Tag) throws -> ResponseRepresentable {
        return try AdminViewContext(menuType: .tags).formView("admin/new-tag", context: tag.makeJSON(), for: request)
    }
    
    func update(request: Request, tag: Tag) throws -> ResponseRepresentable {
        try tag.update(for: request)
        try tag.save()
        
        guard let id = tag.id?.int else {
            throw Abort.serverError
        }
        
        return Response(redirect: "/admin/tags/\(id)/edit")
    }
    
    func destroy(request: Request, tags: [Tag]) throws -> ResponseRepresentable {
        
        try tags.forEach {
            try $0.delete()
        }
        
        return Response(redirect: "/admin/tags")
    }
}


