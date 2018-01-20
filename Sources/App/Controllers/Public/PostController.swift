import Vapor
import HTTP

final class PostController: ResourceRepresentable {
    
    struct ContextMaker {
        
        static func makeIndexView() -> PublicViewContext {
            return PublicViewContext(path: "public/posts")
        }
        
        static func makeShowView() -> PublicViewContext {
            return PublicViewContext(path: "public/post")
        }
    }
    
    func makeResource() -> Resource<Post> {
        return Resource(
            index: index,
            show: show
        )
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        let page = try Post.makeQuery().publicAll().paginate(for: request).makeJSON()
        return try ContextMaker.makeIndexView().makeResponse(context: page, for: request)
    }
    
    func index(request: Request, inTag tag: Tag) throws -> ResponseRepresentable {
        var page = try tag.posts.makeQuery().publicAll().paginate(for: request).makeJSON()
        try page.set("tag", tag.makeJSON())
        return try ContextMaker.makeIndexView().makeResponse(context: page, for: request)
    }
    
    func index(request: Request, inCategory category: Category) throws -> ResponseRepresentable {
        var page = try category.posts.makeQuery().publicAll().paginate(for: request).makeJSON()
        try page.set("category", category.makeJSON())
        return try ContextMaker.makeIndexView().makeResponse(context: page, for: request)
    }
    
    func indexNoCategory(request: Request) throws -> ResponseRepresentable {
        var page = try Post.makeQuery().publicAll().filter(Category.foreignIdKey, nil).paginate(for: request).makeJSON()
        try page.set("category", Category.makeNonCategorized())
        return try ContextMaker.makeIndexView().makeResponse(context: page, for: request)
    }

    func show(request: Request, post: Post) throws -> ResponseRepresentable {
        return try ContextMaker.makeShowView().addTitle(post.title).makeResponse(context: post.makeJSON(), for: request)
    }
}

