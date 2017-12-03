import Vapor
import HTTP

final class PostController: ResourceRepresentable {
    
    func makeResource() -> Resource<Post> {
        return Resource(
            index: index,
            show: show
        )
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        let page = try Post.makeQuery().paginate(for: request).makeJSON()
        return try PublicViewContext().formView("public/posts", context: page, for: request)
    }

    func show(request: Request, post: Post) throws -> ResponseRepresentable {
        return try PublicViewContext().formView("public/post", context: post.makeJSON(), for: request)
    }
}

