import Vapor

final class AdminRoutes: RouteCollection, EmptyInitializable {
    
    func build(_ builder: RouteBuilder) throws {
        
        let admin = builder.grouped("admin")
        
        admin.editableResource("tags", AdminTagController())
    }
}
