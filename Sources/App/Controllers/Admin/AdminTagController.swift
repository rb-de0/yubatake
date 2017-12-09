import HTTP
import Vapor
import Validation

final class AdminTagController: EditableResourceRepresentable {
    
    struct ContextMaker {
        
        static func makeIndexView() -> AdminViewContext {
            return AdminViewContext(path: "admin/tags", menuType: .tags)
        }
        
        static func makeCreateView() -> AdminViewContext {
            return AdminViewContext(path: "admin/new-tag", menuType: .tags)
        }
    }
    
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
        return try ContextMaker.makeIndexView().makeResponse(context: page, for: request)
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        return try ContextMaker.makeCreateView().makeResponse(for: request)
    }
    
    func store(request: Request) throws -> ResponseRepresentable {
        
        do {
            
            let tag = try Tag(request: request)
            try tag.save()
            
            guard let id = tag.id?.int else {
                throw Abort.serverError
            }
            
            return Response(redirect: "/admin/tags/\(id)/edit")
            
        } catch {
            
            return Response(redirect: "/admin/tags/create", withError: error, for: request)
        }
    }
    
    func edit(request: Request, tag: Tag) throws -> ResponseRepresentable {
        return try ContextMaker.makeCreateView().makeResponse(context: tag.makeJSON(), for: request)
    }
    
    func update(request: Request, tag: Tag) throws -> ResponseRepresentable {
        
        guard let id = tag.id?.int else {
            throw Abort.serverError
        }
        
        do {
            
            try tag.update(for: request)
            try tag.save()
        
            return Response(redirect: "/admin/tags/\(id)/edit")
            
        } catch {
            
            return Response(redirect: "/admin/tags/\(id)/edit", withError: error, for: request)
        }
    }
    
    func destroy(request: Request, tags: [Tag]) throws -> ResponseRepresentable {
        
        try tags.forEach {
            try $0.delete()
        }
        
        return Response(redirect: "/admin/tags")
    }
}


