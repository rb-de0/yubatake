import Vapor
import HTTP

final class PostController: ResourceRepresentable {
    
    func index(_ req: Request) throws -> ResponseRepresentable {
        return try Post.all().makeJSON()
    }

    func makeResource() -> Resource<Post> {
        return Resource(
            index: index
        )
    }
}

