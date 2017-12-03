import Vapor

final class PublicRoutes: RouteCollection, EmptyInitializable {
    
    func build(_ builder: RouteBuilder) throws {
        
        builder.resource("/", PostController())
        builder.resource("/posts", PostController())
    }
}
