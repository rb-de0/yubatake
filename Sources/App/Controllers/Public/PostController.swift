import Fluent
import Vapor

final class PostController {

    private struct Keys {
        static let tag = "tag"
        static let category = "category"
    }

    private struct ContextMaker {
        static func makeIndexView() -> PublicViewContext {
            return PublicViewContext(path: "posts")
        }

        static func makeShowView(title: String) -> PublicViewContext {
            return PublicViewContext(path: "post", title: title)
        }
    }

    func index(request: Request) throws -> EventLoopFuture<View> {
        return Post.query(on: request.db).publicAll().noStaticAll().withRelated()
            .paginate(for: request)
            .flatMapThrowing { page -> PageResponse<Post.Public> in
                let posts = try page.items.map { try $0.formPublic() }
                let publicPage = Page<Post.Public>(items: posts, metadata: page.metadata)
                let pageResponse = PageResponse(page: publicPage)
                return pageResponse
            }
            .flatMap { page in
                do {
                    return try ContextMaker.makeIndexView().makeResponse(context: page, for: request)
                } catch {
                    return request.eventLoop.future(error: error)
                }
            }
    }

    func indexInTag(request: Request) throws -> EventLoopFuture<View> {
        guard let tagId = request.parameters.get("id", as: Int.self) else {
            throw Abort(.notFound)
        }
        return Tag.query(on: request.db).filter(\.$id == tagId).withRelated().first()
            .unwrap(or: Abort(.notFound))
            .flatMap { tag -> EventLoopFuture<View> in
                tag.$posts.query(on: request.db).publicAll().noStaticAll().withRelated()
                    .paginate(for: request)
                    .flatMapThrowing { page -> PageResponse<Post.Public> in
                        let posts = try page.items.map { try $0.formPublic() }
                        let publicPage = Page<Post.Public>(items: posts, metadata: page.metadata)
                        let pageResponse = PageResponse(page: publicPage)
                        return pageResponse
                    }
                    .flatMap { page in
                        do {
                            let context = page.add("tag", tag)
                            return try ContextMaker.makeIndexView().makeResponse(context: context, for: request)
                        } catch {
                            return request.eventLoop.future(error: error)
                        }
                    }
            }
    }

    func indexInCategory(request: Request) throws -> EventLoopFuture<View> {
        guard let categoryId = request.parameters.get("id", as: Int.self) else {
            throw Abort(.notFound)
        }
        return Category.query(on: request.db).filter(\.$id == categoryId).withRelated().first()
            .unwrap(or: Abort(.notFound))
            .flatMap { category -> EventLoopFuture<View> in
                category.$posts.query(on: request.db).publicAll().noStaticAll().withRelated()
                    .paginate(for: request)
                    .flatMapThrowing { page -> PageResponse<Post.Public> in
                        let posts = try page.items.map { try $0.formPublic() }
                        let publicPage = Page<Post.Public>(items: posts, metadata: page.metadata)
                        let pageResponse = PageResponse(page: publicPage)
                        return pageResponse
                    }
                    .flatMap { page in
                        do {
                            let context = page.add("category", category)
                            return try ContextMaker.makeIndexView().makeResponse(context: context, for: request)
                        } catch {
                            return request.eventLoop.future(error: error)
                        }
                    }
            }
    }

    func indexNoCategory(request: Request) throws -> EventLoopFuture<View> {
        return Post.query(on: request.db).publicAll().noCategoryAll().withRelated()
            .paginate(for: request)
            .flatMapThrowing { page -> PageResponse<Post.Public> in
                let posts = try page.items.map { try $0.formPublic() }
                let publicPage = Page<Post.Public>(items: posts, metadata: page.metadata)
                let pageResponse = PageResponse(page: publicPage)
                return pageResponse
            }
            .flatMap { page in
                do {
                    return try ContextMaker.makeIndexView().makeResponse(context: page, for: request)
                } catch {
                    return request.eventLoop.future(error: error)
                }
            }
    }

    func show(request: Request) throws -> EventLoopFuture<View> {
        guard let postId = request.parameters.get("id", as: Int.self) else {
            throw Abort(.notFound)
        }
        return Post.query(on: request.db).filter(\.$id == postId).withRelated()
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { post in
                guard post.isPublished else {
                    return request.eventLoop.future(error: Abort(.notFound))
                }
                do {
                    let publicPost = try post.formPublic()
                    return try ContextMaker.makeShowView(title: publicPost.post.title).makeResponse(context: publicPost, for: request)
                } catch {
                    return request.eventLoop.future(error: error)
                }
            }
    }
}
