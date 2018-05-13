import FluentMySQL
import Pagination
import Vapor

final class AdminPostController {
    
    private struct Keys {
        static let isStatic = "is_static"
    }
    
    private struct ContextMaker {
        
        static func makeIndexView(menuType: AdminMenuType = .posts) -> AdminViewContext {
            return AdminViewContext(path: "admin/posts", menuType: menuType)
        }
        
        static func makeCreateView(menuType: AdminMenuType = .posts) -> AdminViewContext {
            return AdminViewContext(path: "admin/new-post", menuType: menuType)
        }
    }
    
    private struct TagsAndCategories: Encodable {
        
        let tags: Future<[Tag]>
        let categories: Future<[Category]>
        
        static func make(from request: Request) -> TagsAndCategories {
            let tags = Tag.query(on: request).all()
            let categories = Category.query(on: request).all()
            return TagsAndCategories(tags: tags, categories: categories)
        }
    }
    
    private struct EditViewContext: Encodable {
        
        private enum CodingKeys: String, CodingKey {
            case post
        }
        
        let post: Post.Public
        let tagsAndCategories: TagsAndCategories
        
        func encode(to encoder: Encoder) throws {
            try tagsAndCategories.encode(to: encoder)
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(post, forKey: .post)
        }
    }
    
    // MARK: - Controller Logic
    
    func index(request: Request) throws -> Future<View> {
        
        return try Post.query(on: request).publicAll().paginate(for: request)
            .flatMap { page in
                try page.data.map { try $0.formPublic(on: request) }
                    .flatten(on: request)
                    .map { posts in
                        try page.transform(posts)
                    }
            }
            .flatMap { page in
                try ContextMaker.makeIndexView().makeResponse(context: page.response(), formDataType: PostForm.self, for: request)
            }
    }
    
    func indexStaticContent(request: Request) throws -> Future<View> {
        
        return try Post.query(on: request).staticAll().paginate(for: request)
            .flatMap { page in
                try page.data.map { try $0.formPublic(on: request) }
                    .flatten(on: request)
                    .map { posts in
                        try page.transform(posts)
                    }
            }
            .flatMap { page in
                let context = page.response().add(Keys.isStatic, true)
                return try ContextMaker.makeIndexView(menuType: .staticContent).makeResponse(context: context, formDataType: PostForm.self, for: request)
            }
    }
    
    func create(request: Request) throws -> Future<View> {
        
        return try ContextMaker.makeCreateView(menuType: .newPost)
            .makeResponse(context: TagsAndCategories.make(from: request), formDataType: PostForm.self, for: request)
    }
    
    func store(request: Request, form: PostForm) throws -> Future<Response> {

        let saveTransaction = request.withPooledConnection(to: .mysql) { conn -> Future<Post> in
            
            let newPost = try Post(from: form, on: request)
            let tags = try Tag.tags(from: form)
            
            return Post.Database.inTransaction(on: conn) { transaction in
                
                newPost.save(on: transaction).flatMap { post in
                    
                    return try Tag.notInsertedTags(in: tags, on: transaction)
                        .flatMap { notInsertedTags in
                            Future<Void>.andAll(notInsertedTags.map { $0.save(on: transaction).transform(to: ()) }, eventLoop: request.eventLoop)
                        }
                        .flatMap { _ in
                            try Tag.insertedTags(in: tags, on: transaction)
                        }
                        .flatMap { insertedTags in
                            Future<Void>.andAll(insertedTags.map { post.tags.attach($0, on: transaction).transform(to: ()) }, eventLoop: request.eventLoop)
                        }
                        .transform(to: post)
                }
            }
        }
        
        return saveTransaction
            .map { post in
                let id = try post.requireID()
                if form.shouldTweet {
                    try request.make(TwitterRepository.self).post(post, on: request)
                }
                return request.redirect(to: "/admin/posts/\(id)/edit")
            }
            .catchMap { error in
                return try request.redirect(to: "/admin/posts/create", with: FormError(error: error, formData: form))
            }
    }
    
    func edit(request: Request) throws -> Future<View> {
        
        return try request.parameters.next(Post.self)
            .flatMap { post in
                try post.formPublic(on: request)
            }
            .flatMap { post in
                let context = EditViewContext(post: post, tagsAndCategories: TagsAndCategories.make(from: request))
                return try ContextMaker.makeCreateView().makeResponse(context: context, formDataType: PostForm.self, for: request)
            }
    }
    
    func update(request: Request, form: PostForm) throws -> Future<Response> {
        
        let existingPost = try request.parameters.next(Post.self)
        let tags = try Tag.tags(from: form)
        
        return existingPost.flatMap { post in
            
            let postId = try post.requireID()
            
            let updateTransaction = request.withPooledConnection(to: .mysql) { conn -> Future<Void> in
                
                let applied = try post.apply(form: form, on: request)
                
                return Post.Database.inTransaction(on: conn) { transaction in
                    
                    applied.save(on: transaction).flatMap { post in
                        
                        return try Tag.notInsertedTags(in: tags, on: transaction)
                            .flatMap { notInsertedTags in
                                Future<Void>.andAll(notInsertedTags.map { $0.save(on: transaction).transform(to: ()) }, eventLoop: request.eventLoop)
                            }
                            .flatMap { _ in
                                try Tag.insertedTags(in: tags, on: transaction)
                            }
                            .flatMap { insertedTags in
                                let refresh = insertedTags.map { tag in
                                    post.tags.detach(tag, on: transaction).flatMap {
                                        post.tags.attach(tag, on: transaction).transform(to: ())
                                    }
                                }
                                return Future<Void>.andAll(refresh, eventLoop: request.eventLoop)
                            }
                    }
                }
            }
            
            return updateTransaction
                .map {
                    request.redirect(to: "/admin/posts/\(postId)/edit")
                }
                .catchMap { error in
                    try request.redirect(to: "/admin/posts/\(postId)/edit", with: FormError(error: error, formData: form))
                }
        }
    }
    
    func delete(request: Request, form: DeletePostsForm) throws -> Future<Response> {
        
        var isStatic = false
        let ids = form.posts ?? []
        let eventLoop = request.eventLoop
        let deletePosts = try ids
            .map {
                try Post.find($0, on: request)
                    .unwrap(or: Abort(.badRequest))
                    .do { isStatic = $0.isStatic }
                    .delete(on: request)
                    .transform(to: ())
            }
        
        return Future<Void>.andAll(deletePosts, eventLoop: eventLoop)
            .map {
                isStatic ? request.redirect(to: "/admin/static-contents") : request.redirect(to: "/admin/posts")
            }
    }
}
