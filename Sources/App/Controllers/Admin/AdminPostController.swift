import Fluent
import Vapor

final class AdminPostController {

    private struct ContextMaker {
        static func makeIndexView(menuType: AdminMenuType = .posts) -> AdminViewContext {
            return AdminViewContext(path: "posts", menuType: menuType)
        }

        static func makeCreateView(menuType: AdminMenuType = .posts) -> AdminViewContext {
            return AdminViewContext(path: "new-post", menuType: menuType)
        }

        static func makePreviewView(title: String) -> PublicViewContext {
            return PublicViewContext(path: "post", title: title)
        }
    }

    private struct TagsAndCategories: Encodable {
        let tags: [Tag]
        let categories: [Category]

        static func make(from request: Request) -> EventLoopFuture<TagsAndCategories> {
            let tags = Tag.query(on: request.db).all()
            let categories = Category.query(on: request.db).all()
            return tags.and(categories).map {
                TagsAndCategories(tags: $0.0, categories: $0.1)
            }
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

    func index(request: Request) throws -> EventLoopFuture<View> {
        return Post.query(on: request.db).noStaticAll().withRelated()
            .paginate(for: request)
            .flatMap { page -> EventLoopFuture<PageResponse<Post.Public>> in
                do {
                    let posts = try page.items.map { try $0.formPublic() }
                    let page = Page<Post.Public>(items: posts, metadata: page.metadata)
                    let pageResponse = PageResponse(page: page)
                    return request.eventLoop.future(pageResponse)
                } catch {
                    return request.eventLoop.future(error: error)
                }
            }
            .flatMap { page in
                do {
                    let response = try ContextMaker.makeIndexView().makeResponse(context: page, for: request)
                    return response
                } catch {
                    return request.eventLoop.future(error: error)
                }
            }
    }

    func indexStaticContent(request: Request) throws -> EventLoopFuture<View> {
        return Post.query(on: request.db).staticAll().withRelated()
            .paginate(for: request)
            .flatMap { page -> EventLoopFuture<PageResponse<Post.Public>> in
                do {
                    let posts = try page.items.map { try $0.formPublic() }
                    let page = Page<Post.Public>(items: posts, metadata: page.metadata)
                    let pageResponse = PageResponse(page: page)
                    return request.eventLoop.future(pageResponse)
                } catch {
                    return request.eventLoop.future(error: error)
                }
            }
            .flatMap { page in
                do {
                    let context = page.add("isStatic", true)
                    let response = try ContextMaker.makeIndexView(menuType: .staticContent).makeResponse(context: context, for: request)
                    return response
                } catch {
                    return request.eventLoop.future(error: error)
                }
            }
    }

    func create(request: Request) throws -> EventLoopFuture<View> {
        return TagsAndCategories.make(from: request)
            .flatMap { tagAndCategories in
                do {
                    return try ContextMaker.makeCreateView(menuType: .newPost)
                        .makeResponse(context: tagAndCategories, formDataType: PostForm.self, for: request)
                } catch {
                    return request.eventLoop.future(error: error)
                }
            }
    }

    func store(request: Request) throws -> EventLoopFuture<Response> {
        let form = try request.content.decode(PostForm.self)
        let userId = try request.auth.require(User.self).requireID()
        let newPost = try Post(from: form, userId: userId)
        let tags = Tag.tags(from: form)
        do {
            try PostForm.validate(request)
        } catch {
            let response = try request.redirect(to: "/admin/posts/create", with: FormError(error: error, formData: form))
            return request.eventLoop.future(response)
        }
        let saveTransaction = request.db.transaction { tx in
            return newPost.save(on: tx)
                .flatMap {
                    Tag.notInsertedTags(in: tags, on: tx)
                        .flatMap { notInsertedTags in
                            EventLoopFuture<Void>.andAllSucceed(notInsertedTags.map { $0.save(on: tx).transform(to: ()) }, on: request.eventLoop)
                        }
                        .flatMap { _ -> EventLoopFuture<[Tag]> in
                            Tag.insertedTags(in: tags, on: tx)
                        }
                        .flatMap { insertedTags in
                            EventLoopFuture<Void>.andAllSucceed(insertedTags.map { newPost.$tags.attach($0, on: tx).transform(to: ()) }, on: request.eventLoop)
                        }
                        .transform(to: newPost)
                }
        }
        return saveTransaction
            .flatMapThrowing { post -> Response in
                let id = try post.requireID()
                if form.shouldTweet {
                    try request.application.twitterRepository.post(post, on: request)
                }
                return request.redirect(to: "/admin/posts/\(id)/edit")
            }
            .flatMapErrorThrowing { error in
                try request.redirect(to: "/admin/posts/create", with: FormError(error: error, formData: form))
            }
    }

    func edit(request: Request) throws -> EventLoopFuture<View> {
        guard let postId = request.parameters.get("id", as: Int.self) else {
            throw Abort(.notFound)
        }
        return Post.query(on: request.db).filter(\.$id == postId).withRelated()
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing {
                try $0.formPublic()
            }
            .flatMap { post in
                TagsAndCategories.make(from: request)
                    .flatMap { tagAndCategories in
                        do {
                            let context = EditViewContext(post: post, tagsAndCategories: tagAndCategories)
                            return try ContextMaker.makeCreateView().makeResponse(context: context, formDataType: PostForm.self, for: request)
                        } catch {
                            return request.eventLoop.future(error: error)
                        }
                    }
            }
    }

    func update(request: Request) throws -> EventLoopFuture<Response> {
        guard let postId = request.parameters.get("id", as: Int.self) else {
            throw Abort(.notFound)
        }
        let form = try request.content.decode(PostForm.self)
        let userId = try request.auth.require(User.self).requireID()
        let tags = Tag.tags(from: form)
        do {
            try PostForm.validate(request)
        } catch {
            let response = try request.redirect(to: "/admin/posts/\(postId)/edit", with: FormError(error: error, formData: form))
            return request.eventLoop.future(response)
        }
        return Post.query(on: request.db).filter(\.$id == postId).withRelated()
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing { post -> Post in
                try post.apply(form: form, userId: userId)
                return post
            }
            .flatMap { post in
                request.db.transaction { tx -> EventLoopFuture<Post> in
                    post.save(on: tx)
                        .flatMap {
                            Tag.notInsertedTags(in: tags, on: tx)
                                .flatMap { notInsertedTags in
                                    EventLoopFuture<Void>.andAllSucceed(notInsertedTags.map { $0.save(on: tx).transform(to: ()) }, on: request.eventLoop)
                                }
                                .flatMap { _ -> EventLoopFuture<[Tag]> in
                                    Tag.insertedTags(in: tags, on: tx)
                                }
                                .flatMap { insertedTags in
                                    post.$tags.detach(insertedTags, on: tx).transform(to: insertedTags)
                                }
                                .flatMap { insertedTags in
                                    EventLoopFuture<Void>.andAllSucceed(insertedTags.map { post.$tags.attach($0, on: tx).transform(to: ()) }, on: request.eventLoop)
                                }
                                .transform(to: post)
                        }
                }
            }
            .map { _ in
                request.redirect(to: "/admin/posts/\(postId)/edit")
            }
            .flatMapErrorThrowing { error in
                try request.redirect(to: "/admin/posts/\(postId)/edit", with: FormError(error: error, formData: form))
            }
    }

    func delete(request: Request) throws -> EventLoopFuture<Response> {
        let form = try request.content.decode(DeletePostsForm.self)
        let ids = form.posts
        let forStaticContents = request.headers[.referer].first?.contains("static-contents") == true
        return Post.query(on: request.db).filter(\.$id ~~ ids)
            .delete()
            .map {
                forStaticContents ? request.redirect(to: "/admin/static-contents") : request.redirect(to: "/admin/posts")
            }
    }

    func showPreview(request: Request) throws -> EventLoopFuture<View> {
        guard let postId = request.parameters.get("id", as: Int.self) else {
            throw Abort(.notFound)
        }
        return Post.query(on: request.db).filter(\.$id == postId).withRelated()
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { post in
                do {
                    let publicPost = try post.formPublic()
                    return try ContextMaker.makePreviewView(title: publicPost.post.title).makeResponse(context: publicPost, for: request)
                } catch {
                    return request.eventLoop.future(error: error)
                }
            }
    }
}
