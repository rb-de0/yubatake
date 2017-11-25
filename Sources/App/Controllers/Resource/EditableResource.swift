import FluentProvider
import HTTP

final class EditableResource<Model: Parameterizable> {
    
    typealias Item = (Request, Model) throws -> ResponseRepresentable
    typealias Items = (Request, [Model]) throws -> ResponseRepresentable
    
    let resource: Resource<Model>
    let update: Item?
    let destroy: Items?
    let destroyKey: String?
    
    init(resource: Resource<Model>, update: Item? = nil, destroy: Items? = nil, destroyKey: String? = nil) {
        self.resource = resource
        self.update = update
        self.destroy = destroy
        self.destroyKey = destroyKey
    }
}

protocol EditableResourceRepresentable {
    associatedtype Model: FluentProvider.Model
    func makeResource() -> EditableResource<Model>
}

extension RouteBuilder {
    
    func editableResource<EditableResource: EditableResourceRepresentable>(_ path: String, _ editableResource: EditableResource) {
        
        let editableResource = editableResource.makeResource()
        resource(path, editableResource.resource)
        
        func item(_ method: Method, _ subpath: String, _ item: Resource<EditableResource.Model>.Item?) {
            
            guard let item = item else {
                return
            }
            
            let closure: (Request) throws -> ResponseRepresentable = { request in
                let model = try request.parameters.next(EditableResource.Model.self)
                return try item(request, model).makeResponse()
            }
            
            add(method, path, EditableResource.Model.parameter, subpath) { request in
                return try closure(request)
            }
        }
        
        func delete() {
            
            guard let items = editableResource.destroy, let destoryKey = editableResource.destroyKey else {
                return
            }
            
            let closure: (Request) throws -> ResponseRepresentable = { request in
                
                let deleteItems: [EditableResource.Model]
                
                if let ids = request.data[destoryKey]?.array {
                    deleteItems = try ids.flatMap { try EditableResource.Model.find($0) }
                } else {
                    deleteItems = []
                }
                
                return try items(request, deleteItems).makeResponse()
            }
            
            add(.post, path, "delete") { request in
                return try closure(request)
            }
        }

        item(.post, "edit", editableResource.update)
        delete()
    }
}
