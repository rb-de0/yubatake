import FluentProvider
import HTTP
import Vapor


final class AdminPostController: EditableResourceRepresentable {
    
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
    
    
    func index(request: Request) throws -> ResponseRepresentable {
        let page = try Post.makeQuery().paginate(for: request).makeJSON()
        return try AdminViewCreator.create("admin/posts", context: page, for: request)
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        return try AdminViewCreator.create("admin/new-post", context: tagsAndCategories(), for: request)
    }
    
    func store(request: Request) throws -> ResponseRepresentable {
        
        let post = Post(request: request)
        try post.save()
        
        let tagParams = try Tag.tags(from: request)
        try Tag.notInsertedTags(in: tagParams).forEach {
            try $0.save()
        }
        let tags = try Tag.insertedTags(in: tagParams)
        
        try tags.forEach {
            try post.tags.add($0)
        }
        
        guard let id = post.id?.int else {
            throw Abort.serverError
        }
        
        return Response(redirect: "/admin/posts/\(id)/edit")
    }
    
    func edit(request: Request, post: Post) throws -> ResponseRepresentable {
        var context = try tagsAndCategories()
        try context.set("post", post.makeJSON())
        return try AdminViewCreator.create("admin/new-post", context: context, for: request)
    }
    
    func update(request: Request, post: Post) throws -> ResponseRepresentable {
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
        
        guard let id = post.id?.int else {
            throw Abort.serverError
        }
        
        return Response(redirect: "/admin/posts/\(id)/edit")
    }
    
    func destroy(request: Request, posts: [Post]) throws -> ResponseRepresentable {
        
        try posts.forEach {
            try $0.delete()
        }
        
        return Response(redirect: "/admin/posts")
    }
    
    private func tagsAndCategories() throws -> JSON {
        let tags = try Tag.all().makeJSON()
        let categories = try Category.all().makeJSON()
        return JSON(["tags": tags, "categories": categories])
        
    }
}


