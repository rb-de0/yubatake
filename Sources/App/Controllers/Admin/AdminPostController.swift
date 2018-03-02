import FluentProvider
import HTTP
import Vapor
import Validation

final class AdminPostController: EditableResourceRepresentable {
    
    struct ContextMaker {
        
        static func makeIndexView() -> AdminViewContext {
            return AdminViewContext(path: "admin/posts", menuType: .posts)
        }
        
        static func makeCreateView() -> AdminViewContext {
            return AdminViewContext(path: "admin/new-post", menuType: .posts, formDataDeliverer: Post.self)
        }
    }
    
    func makeResource() -> EditableResource<Post> {
        
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
            destroyKey: "posts"
        )
    }
    
    private lazy var repository = resolve(TwitterRepository.self)
    
    func index(request: Request) throws -> ResponseRepresentable {
        let page = try Post.makeQuery().publicAll().paginate(for: request).makeJSON()
        return try ContextMaker.makeIndexView().makeResponse(context: page, for: request)
    }
    
    func indexStaticContent(request: Request) throws -> ResponseRepresentable {
        var page = try Post.makeQuery().staticAll().paginate(for: request).makeJSON()
        try page.set(Post.isStaticKey, true)
        return try ContextMaker.makeIndexView().addMenu(.staticContent).makeResponse(context: page, for: request)
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        return try ContextMaker.makeCreateView()
            .addMenu(.newPost)
            .makeResponse(context: tagsAndCategories(), for: request)
    }
    
    func store(request: Request) throws -> ResponseRepresentable {
        
        do {
            
            let post = try Post(request: request)
            try post.save()
            
            let tagParams = try Tag.tags(from: request)
            try Tag.notInsertedTags(in: tagParams).forEach {
                try $0.save()
            }
            let tags = try Tag.insertedTags(in: tagParams)
            
            try tags.forEach {
                try post.tags.add($0)
            }
            
            let id = try post.assertId()
            
            if let _ = request.data["should-tweet"]?.string {
                let user = try request.auth.assertAuthenticated(User.self)
                try repository.tweetNewPost(post, from: user, on: request)
            }
            
            return Response(redirect: "/admin/posts/\(id)/edit")
            
        } catch {
            
            return Response(redirect: "/admin/posts/create", with: FormError(error: error, deliverer: Post.self), for: request)
        }
    }
    
    func edit(request: Request, post: Post) throws -> ResponseRepresentable {
        var context = try tagsAndCategories()
        try context.set("post", post.makeJSON())
        return try ContextMaker.makeCreateView().makeResponse(context: context, for: request)
    }
    
    func update(request: Request, post: Post) throws -> ResponseRepresentable {
        
        let id = try post.assertId()
        
        do {
            
            try post.update(for: request)
            try post.save()
            
            let tagParams = try Tag.tags(from: request)
            try Tag.notInsertedTags(in: tagParams).forEach {
                try $0.save()
            }
            let tags = try Tag.insertedTags(in: tagParams)
            
            try Tag.database?.transaction { conn in
                
                try post.tags.all().forEach {
                    try Pivot<Post, Tag>.detach(executor: conn, post, $0)
                }
                
                try tags.forEach {
                    try Pivot<Post, Tag>.attach(executor: conn, post, $0)
                }
            }
            
            return Response(redirect: "/admin/posts/\(id)/edit")
            
        } catch {
            
            return Response(redirect: "/admin/posts/\(id)/edit", with: FormError(error: error, deliverer: Post.self), for: request)
        }
    }
    
    func destroy(request: Request, posts: [Post]) throws -> ResponseRepresentable {
        
        let isStatic = posts.first?.isStatic ?? false
        
        try posts.forEach {
            try $0.delete()
        }
        
        return isStatic ? Response(redirect: "/admin/static-contents") : Response(redirect: "/admin/posts")
    }
    
    // MARK: - Private
    
    private func tagsAndCategories() throws -> JSON {
        let tags = try Tag.all().makeJSON()
        let categories = try Category.all().makeJSON()
        return JSON(["tags": tags, "categories": categories])
    }
}
