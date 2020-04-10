@testable import App
import XCTVapor

final class AdminPostControllerTests: ControllerTestCase {
    
    func testCanViewIndex() throws {
        try test(.GET, "/admin/posts") { response in
            XCTAssertEqual(response.status, .ok)
        }
        let post = DataMaker.makePost(title: "title", content: "content", htmlContent: "htmlContent", partOfContent: "partOfContent", userId: 1)
        try post.save(on: db).wait()
        try test(.GET, "/admin/posts") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("items")?.array?.count, 1)
            XCTAssertEqual(view.get("metadata.total")?.int, 1)
            XCTAssertEqual(view.get("metadata.page")?.int, 1)
            XCTAssertEqual(view.get("metadata.totalPage")?.int, 1)
        }
    }
    
    func testCanViewPageButtonAtTwoPages() throws {
        try (1...11).forEach { i in
            let post = DataMaker.makePost(title: "title", content: "content", htmlContent: "htmlContent", partOfContent: "partOfContent", userId: 1)
            try post.save(on: db).wait()
        }
        try test(.GET, "/admin/posts") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("metadata.total")?.int, 11)
            XCTAssertEqual(view.get("metadata.page")?.int, 1)
            XCTAssertEqual(view.get("metadata.totalPage")?.int, 2)
        }
        try test(.GET, "/admin/posts?page=2") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("metadata.total")?.int, 11)
            XCTAssertEqual(view.get("metadata.page")?.int, 2)
            XCTAssertEqual(view.get("metadata.totalPage")?.int, 2)
        }
    }
    
    func testCanViewStaticContent() throws {
        let post = DataMaker.makePost(title: "title", content: "content", htmlContent: "htmlContent", partOfContent: "partOfContent", userId: 1, isStatic: true)
        try post.save(on: db).wait()
        try test(.GET, "/admin/static-contents") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("items")?.array?.count, 1)
            XCTAssertEqual(view.get("metadata.total")?.int, 1)
            XCTAssertEqual(view.get("metadata.page")?.int, 1)
            XCTAssertEqual(view.get("metadata.totalPage")?.int, 1)
        }
    }
    
    func testCanViewCreateView() throws {
        try test(.GET, "/admin/posts/create") { response in
            XCTAssertEqual(response.status, .ok)
        }
    }
    
    func testCanViewEditView() throws {
        try test(.GET, "/admin/posts/1/edit") { response in
            XCTAssertEqual(response.status, .notFound)
        }
        let post = DataMaker.makePost(title: "title", content: "content", htmlContent: "htmlContent", partOfContent: "partOfContent", userId: 1)
        try post.save(on: db).wait()
        try test(.GET, "/admin/posts/1/edit") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("post.title")?.string, "title")
            XCTAssertEqual(view.get("post.content")?.string, "content")
            XCTAssertNil(view.get("post.category.id"))
            XCTAssertEqual(view.get("post.tagsString")?.string, "")
            XCTAssertEqual(view.get("post.isStatic")?.bool, false)
            XCTAssertEqual(view.get("post.isPublished")?.bool, true)
        }
    }
    
    func testCanDestroyPosts() throws {
        let post = DataMaker.makePost(title: "title", content: "content", htmlContent: "htmlContent", partOfContent: "partOfContent", userId: 1)
        try post.save(on: db).wait()
        try test(.POST, "/admin/posts/delete", body: "posts[]=1") { response in
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers.first(name: .location), "/admin/posts")
        }
        try test(.GET, "/admin/posts") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("items")?.array?.count, 0)
        }
    }
    
    func testCanDestroyStaticContents() throws {
        let post = DataMaker.makePost(title: "title", content: "content", htmlContent: "htmlContent", partOfContent: "partOfContent", userId: 1, isStatic: true)
        try post.save(on: db).wait()
        try test(.POST, "/admin/posts/delete", body: "posts[]=1", beforeRequest: { request in
            request.headers.replaceOrAdd(name: .referer, value: "localhost:8080/admin/static-contents")
        }) { response in
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers.first(name: .location), "/admin/static-contents")
        }
        try test(.GET, "/admin/static-contents") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("items")?.array?.count, 0)
        }
    }
    
    func testCanStoreAPost() throws {
        let form = "title=title&content=content&tags=Swift,iOS&isPublished=true"
        try test(.POST, "/admin/posts", body: form) { response in
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers.first(name: .location), "/admin/posts/1/edit")
        }
        try test(.GET, "/admin/posts/1/edit") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("post.title")?.string, "title")
            XCTAssertEqual(view.get("post.content")?.string, "content")
            XCTAssertNil(view.get("post.category.id"))
            XCTAssertEqual(view.get("post.tagsString")?.string, "Swift,iOS")
            XCTAssertEqual(view.get("post.isStatic")?.bool, false)
            XCTAssertEqual(view.get("post.isPublished")?.bool, true)
        }
    }
    
    func testCanStoreAStaticPost() throws {
        try DataMaker.makeCategory(name: "category").save(on: db).wait()
        let form = "title=title&content=content&category=1&tags=Swift,iOS&isStatic=true&isPublished=true"
        try test(.POST, "/admin/posts", body: form) { response in
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers.first(name: .location), "/admin/posts/1/edit")
        }
        try test(.GET, "/admin/posts/1/edit") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("post.title")?.string, "title")
            XCTAssertEqual(view.get("post.content")?.string, "content")
            XCTAssertEqual(view.get("post.category.id")?.int, 1)
            XCTAssertEqual(view.get("post.tagsString")?.string, "Swift,iOS")
            XCTAssertEqual(view.get("post.isStatic")?.bool, true)
            XCTAssertEqual(view.get("post.isPublished")?.bool, true)
        }
    }
    
    func testCanStoreADraftPost() throws {
        try DataMaker.makeCategory(name: "category").save(on: db).wait()
        let form = "title=title&content=content&category=1&tags=Swift,iOS&isStatic=false&isPublished=true"
        try test(.POST, "/admin/posts", body: form) { response in
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers.first(name: .location), "/admin/posts/1/edit")
        }
        try test(.GET, "/admin/posts/1/edit") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("post.title")?.string, "title")
            XCTAssertEqual(view.get("post.content")?.string, "content")
            XCTAssertEqual(view.get("post.category.id")?.int, 1)
            XCTAssertEqual(view.get("post.tagsString")?.string, "Swift,iOS")
            XCTAssertEqual(view.get("post.isStatic")?.bool, false)
            XCTAssertEqual(view.get("post.isPublished")?.bool, true)
        }
    }
    
    func testCannotStoreInvalidFormData() throws {
        do {
            let form = "title=&content=content&tags="
            try test(.POST, "/admin/posts", body: form) { response in
                XCTAssertEqual(response.status, .seeOther)
                XCTAssertEqual(response.headers.first(name: .location), "/admin/posts/create")
            }
            try test(.GET, "/admin/posts/create") { response in
                XCTAssertNotNil(view.get("errorMessage"))
            }
        }
        do {
            let form = "title=title&content=&tags="
            try test(.POST, "/admin/posts", body: form) { response in
                XCTAssertEqual(response.status, .seeOther)
                XCTAssertEqual(response.headers.first(name: .location), "/admin/posts/create")
            }
            try test(.GET, "/admin/posts/create") { response in
                XCTAssertNotNil(view.get("errorMessage"))
            }
        }
        do {
            let longTitle = String(repeating: "a", count: 129)
            let form = "title=\(longTitle)&content=content&tags="
            try test(.POST, "/admin/posts", body: form) { response in
                XCTAssertEqual(response.status, .seeOther)
                XCTAssertEqual(response.headers.first(name: .location), "/admin/posts/create")
            }
            try test(.GET, "/admin/posts/create") { response in
                XCTAssertNotNil(view.get("errorMessage"))
            }
        }
        do {
            let longContent = String(repeating: "a", count: 8193)
            let form = "title=title&content=\(longContent)&tags="
            try test(.POST, "/admin/posts", body: form) { response in
                XCTAssertEqual(response.status, .seeOther)
                XCTAssertEqual(response.headers.first(name: .location), "/admin/posts/create")
            }
            try test(.GET, "/admin/posts/create") { response in
                XCTAssertNotNil(view.get("errorMessage"))
            }
        }
    }
    
    func testCannotStoreAPostHasInvalidCategory() throws {
        let form = "title=title&content=content&category=10&tags=Swift,iOS"
        try test(.POST, "/admin/posts", body: form) { response in
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers.first(name: .location), "/admin/posts/create")
        }
    }
    
    func testCanStoreAPostHasNotInsertedTags() throws {
        try DataMaker.makeTag(name: "Swift").save(on: db).wait()
        try DataMaker.makeTag(name: "iOS").save(on: db).wait()
        let form = "title=title&content=content&tags=Android"
        try test(.POST, "/admin/posts", body: form) { response in
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers.first(name: .location), "/admin/posts/1/edit")
        }
        XCTAssertEqual(try Tag.query(on: db).all().wait().count, 3)
    }
    
    func testCanUpdateAPost() throws {
        let post = DataMaker.makePost(title: "title", content: "content", htmlContent: "htmlContent", partOfContent: "partOfContent", userId: 1)
        try post.save(on: db).wait()
        let form = "title=title_after&content=content_after&tags=Android"
        try test(.POST, "/admin/posts/1/edit", body: form) { response in
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers.first(name: .location), "/admin/posts/1/edit")
        }
        try test(.GET, "/admin/posts/1/edit") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("post.title")?.string, "title_after")
            XCTAssertEqual(view.get("post.content")?.string, "content_after")
            XCTAssertEqual(view.get("post.tagsString")?.string, "Android")
        }
    }
    
    func testCannotUpdateInvalidFormData() throws {
        let post = DataMaker.makePost(title: "title", content: "content", htmlContent: "htmlContent", partOfContent: "partOfContent", userId: 1)
        try post.save(on: db).wait()
        do {
            let form = "title=&content=content&tags="
            try test(.POST, "/admin/posts/1/edit", body: form) { response in
                XCTAssertEqual(response.status, .seeOther)
                XCTAssertEqual(response.headers.first(name: .location), "/admin/posts/1/edit")
            }
            try test(.GET, "/admin/posts/1/edit") { response in
                XCTAssertNotNil(view.get("errorMessage"))
            }
            let post = try Post.find(1, on: db).wait()
            XCTAssertEqual(post?.title, "title")
            XCTAssertEqual(post?.content, "content")
        }
        do {
            let form = "title=title&content=&tags="
            try test(.POST, "/admin/posts/1/edit", body: form) { response in
                XCTAssertEqual(response.status, .seeOther)
                XCTAssertEqual(response.headers.first(name: .location), "/admin/posts/1/edit")
            }
            try test(.GET, "/admin/posts/1/edit") { response in
                XCTAssertNotNil(view.get("errorMessage"))
            }
            let post = try Post.find(1, on: db).wait()
            XCTAssertEqual(post?.title, "title")
            XCTAssertEqual(post?.content, "content")
        }
        do {
            let longTitle = String(repeating: "a", count: 129)
            let form = "title=\(longTitle)&content=content&tags="
            try test(.POST, "/admin/posts/1/edit", body: form) { response in
                XCTAssertEqual(response.status, .seeOther)
                XCTAssertEqual(response.headers.first(name: .location), "/admin/posts/1/edit")
            }
            try test(.GET, "/admin/posts/1/edit") { response in
                XCTAssertNotNil(view.get("errorMessage"))
            }
            let post = try Post.find(1, on: db).wait()
            XCTAssertEqual(post?.title, "title")
            XCTAssertEqual(post?.content, "content")
        }
        do {
            let longContent = String(repeating: "a", count: 8193)
            let form = "title=title&content=\(longContent)&tags="
            try test(.POST, "/admin/posts/1/edit", body: form) { response in
                XCTAssertEqual(response.status, .seeOther)
                XCTAssertEqual(response.headers.first(name: .location), "/admin/posts/1/edit")
            }
            try test(.GET, "/admin/posts/1/edit") { response in
                XCTAssertNotNil(view.get("errorMessage"))
            }
            let post = try Post.find(1, on: db).wait()
            XCTAssertEqual(post?.title, "title")
            XCTAssertEqual(post?.content, "content")
        }
    }
}
