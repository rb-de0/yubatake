import Pagination
import Vapor

final class PostController {
    
    private struct Keys {
        static let tag = "tag"
        static let category = "category"
    }
    
    private struct ContextMaker {
        
        static func makeIndexView() -> PublicViewContext {
            return PublicViewContext(path: "public/posts")
        }
        
        static func makeShowView(title: String) -> PublicViewContext {
            return PublicViewContext(path: "public/post", title: title)
        }
    }

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
                try ContextMaker.makeIndexView().makeResponse(context: page.response(), for: request)
            }
    }
    
    func indexInTag(request: Request) throws -> Future<View> {
        return try request.parameters.next(Tag.self).flatMap { tag in
            try tag.posts.query(on: request).publicAll().paginate(for: request)
                .flatMap { page in
                    try page.data.map { try $0.formPublic(on: request) }
                        .flatten(on: request)
                        .map { posts in
                            try page.transform(posts)
                        }
                }
                .flatMap { page in
                    let context = page.response().add(Keys.tag, tag)
                    return try ContextMaker.makeIndexView().makeResponse(context: context, for: request)
                }
        }
    }
    
    func indexInCategory(request: Request) throws -> Future<View> {
        return try request.parameters.next(Category.self).flatMap { category in
            try category.posts.query(on: request).publicAll().paginate(for: request)
                .flatMap { page in
                    try page.data.map { try $0.formPublic(on: request) }
                        .flatten(on: request)
                        .map { posts in
                            try page.transform(posts)
                        }
                }
                .flatMap { page in
                    let context = page.response().add(Keys.category, category)
                    return try ContextMaker.makeIndexView().makeResponse(context: context, for: request)
                }
        }
    }
    
    func indexNoCategory(request: Request) throws -> Future<View> {
        return try Post.query(on: request).noCategoryAll().paginate(for: request)
            .flatMap { page in
                try page.data.map { try $0.formPublic(on: request) }
                    .flatten(on: request)
                    .map { posts in
                        try page.transform(posts)
                    }
            }
            .flatMap { page in
                try ContextMaker.makeIndexView().makeResponse(context: page.response(), for: request)
            }
    }
    
    func show(request: Request) throws -> Future<View> {
        return try request.parameters.next(Post.self).flatMap { post in
            try post.formPublic(on: request).flatMap { publicPost in
                try ContextMaker.makeShowView(title: post.title).makeResponse(context: publicPost, for: request)
            }
        }
    }
}
