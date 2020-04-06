//@testable import App
//import Vapor
//import XCTest
//
//final class AdminPostControllerTests: ControllerTestCase, AdminTestCase {
//    
//    func testCanViewIndex() throws {
//        
//        var response: Response!
//        
//        response = try waitResponse(method: .GET, url: "/admin/posts")
//        
//        XCTAssertEqual(response.http.status, .ok)
//        
//        _ = try DataMaker.makePost(on: app, conn: conn).save(on: conn).wait()
//        
//        XCTAssertEqual(try Post.query(on: conn).count().wait(), 1)
//        
//        response = try waitResponse(method: .GET, url: "/admin/posts")
//        
//        XCTAssertEqual(response.http.status, .ok)
//        XCTAssertEqual(view.get("page.position.max")?.int, 1)
//        XCTAssertEqual(view.get("page.position.current")?.int, 1)
//        XCTAssertNil(view.get("page.position.next"))
//        XCTAssertNil(view.get("page.position.previous"))
//        XCTAssertEqual(view.get("data")?.array?.count, 1)
//    }
//    
//    func testCanViewPageButtonAtTwoPages() throws {
//        
//        try (1...11).forEach { _ in
//            _ = try DataMaker.makePost(on: app, conn: conn).save(on: conn).wait()
//        }
//        
//        XCTAssertEqual(try Post.query(on: conn).count().wait(), 11)
//        
//        var response: Response!
//        
//        response = try waitResponse(method: .GET, url: "/admin/posts")
//        
//        XCTAssertEqual(response.http.status, .ok)
//        XCTAssertEqual(view.get("page.position.max")?.int, 2)
//        XCTAssertEqual(view.get("page.position.current")?.int, 1)
//        XCTAssertEqual(view.get("page.position.next")?.int, 2)
//        XCTAssertNil(view.get("page.position.previous"))
//        XCTAssertEqual(view.get("data")?.array?.count, 10)
//        
//        response = try waitResponse(method: .GET, url: "/admin/posts?page=2")
//        
//        XCTAssertEqual(response.http.status, .ok)
//        XCTAssertEqual(view.get("page.position.max")?.int, 2)
//        XCTAssertEqual(view.get("page.position.current")?.int, 2)
//        XCTAssertNil(view.get("page.position.next"))
//        XCTAssertEqual(view.get("page.position.previous")?.int, 1)
//        XCTAssertEqual(view.get("data")?.array?.count, 1)
//    }
//    
//    func testCanViewPageButtonAtThreePages() throws {
//        
//        try (1...21).forEach { _ in
//            _ = try DataMaker.makePost(on: app, conn: conn).save(on: conn).wait()
//        }
//        
//        XCTAssertEqual(try Post.query(on: conn).count().wait(), 21)
//
//        let response = try waitResponse(method: .GET, url: "/admin/posts?page=2")
//        
//        XCTAssertEqual(response.http.status, .ok)
//        XCTAssertEqual(view.get("page.position.max")?.int, 3)
//        XCTAssertEqual(view.get("page.position.current")?.int, 2)
//        XCTAssertEqual(view.get("page.position.next")?.int, 3)
//        XCTAssertEqual(view.get("page.position.previous")?.int, 1)
//        XCTAssertEqual(view.get("data")?.array?.count, 10)
//    }
//    
//    func testCanViewStaticContent() throws {
//        
//        _ = try DataMaker.makePost(isStatic: true, on: app, conn: conn).save(on: conn).wait()
//        
//        let response = try waitResponse(method: .GET, url: "/admin/static-contents")
//        
//        XCTAssertEqual(response.http.status, .ok)
//        XCTAssertEqual(view.get("page.position.max")?.int, 1)
//        XCTAssertEqual(view.get("page.position.current")?.int, 1)
//        XCTAssertNil(view.get("page.position.next"))
//        XCTAssertNil(view.get("page.position.previous"))
//        XCTAssertEqual(view.get("data")?.array?.count, 1)
//    }
//    
//    func testCanViewCreateView() throws {
//        let response = try waitResponse(method: .GET, url: "/admin/posts/create")
//        XCTAssertEqual(response.http.status, .ok)
//    }
//    
//    func testCanViewEditView() throws {
//        
//        var response: Response!
//        
//        response = try waitResponse(method: .GET, url: "/admin/posts/1/edit")
//        
//        XCTAssertEqual(response.http.status, .notFound)
//        
//        _ = try DataMaker.makePost(on: app, conn: conn).save(on: conn).wait()
//        
//        response = try waitResponse(method: .GET, url: "/admin/posts/1/edit")
//        
//        XCTAssertEqual(response.http.status, .ok)
//    }
//    
//    func testCanDestroyPosts() throws {
//        
//        var response: Response!
//        
//        _ = try DataMaker.makePost(on: app, conn: conn).save(on: conn).wait()
//        
//        response = try waitResponse(method: .POST, url: "/admin/posts/delete") { request in
//            try request.setFormData(["posts": [1]], csrfToken: self.csrfToken)
//        }
//        
//        XCTAssertEqual(response.http.status, .seeOther)
//        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/admin/posts")
//        
//        response = try waitResponse(method: .GET, url: "/admin/posts")
//        
//        XCTAssertEqual(response.http.status, .ok)
//        XCTAssertEqual(view.get("data")?.array?.count, 0)
//        XCTAssertEqual(try Post.query(on: conn).count().wait(), 0)
//    }
//    
//    func testCanDestroyStaticContents() throws {
//        
//        var response: Response!
//        
//        _ = try DataMaker.makePost(isStatic: true, on: app, conn: conn).save(on: conn).wait()
//        
//        response = try waitResponse(method: .POST, url: "/admin/posts/delete") { request in
//            try request.setFormData(["posts": [1]], csrfToken: self.csrfToken)
//        }
//        
//        XCTAssertEqual(response.http.status, .seeOther)
//        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/admin/static-contents")
//        
//        response = try waitResponse(method: .GET, url: "/admin/static-contents")
//        
//        XCTAssertEqual(response.http.status, .ok)
//        XCTAssertEqual(view.get("data")?.array?.count, 0)
//        XCTAssertEqual(try Post.query(on: conn).count().wait(), 0)
//    }
//    
//    // MARK: - Store/Update
//    
//    func testCanStoreAPost() throws {
//        
//        _ = try DataMaker.makeCategory("Programming").save(on: conn).wait()
//        
//        var response: Response!
//        
//        let form = try DataMaker.makePostFormForTest(title: "title", content: "content", categoryId: 1, tags: "Swift,iOS")
//        
//        response = try waitResponse(method: .POST, url: "/admin/posts") { request in
//            try request.setFormData(form, csrfToken: self.csrfToken)
//        }
//        
//        XCTAssertEqual(response.http.status, .seeOther)
//        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/admin/posts/1/edit")
//        XCTAssertEqual(try Post.query(on: conn).count().wait(), 1)
//        XCTAssertEqual(try Tag.query(on: conn).count().wait(), 2)
//        
//        response = try waitResponse(method: .GET, url: "/admin/posts/1/edit")
//        
//        let post = try Post.query(on: conn).first().wait()
//        
//        XCTAssertEqual(response.http.status, .ok)
//        XCTAssertEqual(view.get("post.title")?.string, "title")
//        XCTAssertEqual(view.get("post.content")?.string, "content")
//        XCTAssertEqual(view.get("post.category.id")?.int, 1)
//        XCTAssertEqual(view.get("post.tags_string")?.string, "Swift,iOS")
//        XCTAssertEqual(view.get("post.is_static")?.bool, false)
//        XCTAssertEqual(view.get("post.is_published")?.bool, true)
//        
//        XCTAssertEqual(post?.title, "title")
//        XCTAssertEqual(post?.content, "content")
//        XCTAssertEqual(post?.categoryId, 1)
//        XCTAssertEqual(post?.isStatic, false)
//        XCTAssertEqual(post?.isPublished, true)
//        
//        response = try waitResponse(method: .GET, url: "/admin/posts")
//        
//        XCTAssertEqual(view.get("data")?.array?.count, 1)
//    }
//    
//    func testCanStoreAStaticPost() throws {
//        
//        _ = try DataMaker.makeCategory("Programming").save(on: conn).wait()
//        
//        var response: Response!
//        
//        let form = try DataMaker.makePostFormForTest(title: "title", content: "content", categoryId: 1, tags: "Swift,iOS", isStatic: true)
//        
//        response = try waitResponse(method: .POST, url: "/admin/posts") { request in
//            try request.setFormData(form, csrfToken: self.csrfToken)
//        }
//        
//        XCTAssertEqual(response.http.status, .seeOther)
//        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/admin/posts/1/edit")
//        XCTAssertEqual(try Post.query(on: conn).count().wait(), 1)
//        XCTAssertEqual(try Tag.query(on: conn).count().wait(), 2)
//        
//        response = try waitResponse(method: .GET, url: "/admin/posts/1/edit")
//        
//        let post = try Post.query(on: conn).first().wait()
//        
//        XCTAssertEqual(response.http.status, .ok)
//        XCTAssertEqual(view.get("post.is_static")?.bool, true)
//        XCTAssertEqual(post?.isStatic, true)
//        
//        response = try waitResponse(method: .GET, url: "/admin/posts")
//        XCTAssertEqual(view.get("data")?.array?.count, 0)
//        
//        response = try waitResponse(method: .GET, url: "/admin/static-contents")
//        XCTAssertEqual(view.get("data")?.array?.count, 1)
//    }
//    
//    func testCanStoreADraftPost() throws {
//        
//        _ = try DataMaker.makeCategory("Programming").save(on: conn).wait()
//        
//        var response: Response!
//        
//        let form = try DataMaker.makePostFormForTest(title: "title", content: "content", categoryId: 1, tags: "Swift,iOS", isPublished: false)
//        
//        response = try waitResponse(method: .POST, url: "/admin/posts") { request in
//            try request.setFormData(form, csrfToken: self.csrfToken)
//        }
//        
//        XCTAssertEqual(response.http.status, .seeOther)
//        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/admin/posts/1/edit")
//        XCTAssertEqual(try Post.query(on: conn).count().wait(), 1)
//        XCTAssertEqual(try Tag.query(on: conn).count().wait(), 2)
//        
//        response = try waitResponse(method: .GET, url: "/admin/posts/1/edit")
//        
//        let post = try Post.query(on: conn).first().wait()
//        
//        XCTAssertEqual(response.http.status, .ok)
//        XCTAssertEqual(view.get("post.is_published")?.bool, false)
//        XCTAssertEqual(post?.isPublished, false)
//        
//        response = try waitResponse(method: .GET, url: "/admin/posts")
//        
//        XCTAssertEqual(view.get("data")?.array?.count, 1)
//    }
//    
//    func testCannotStoreAPostHasInvalidCategory() throws {
//        
//        var response: Response!
//        
//        let form = try DataMaker.makePostFormForTest(title: "title", content: "content", categoryId: 10, tags: "Swift,iOS")
//        
//        response = try waitResponse(method: .POST, url: "/admin/posts") { request in
//            try request.setFormData(form, csrfToken: self.csrfToken)
//        }
//        
//        XCTAssertEqual(response.http.status, .seeOther)
//        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/admin/posts/create")
//        XCTAssertEqual(try Post.query(on: conn).count().wait(), 0)
//    }
//    
//    func testCanStoreAPostHasNotInsertedTags() throws {
//        
//        _ = try DataMaker.makeTag("Swift").save(on: conn).wait()
//        _ = try DataMaker.makeTag("iOS").save(on: conn).wait()
//        
//        let form = try DataMaker.makePostFormForTest(title: "title", content: "content", tags: "Vapor")
//        
//        let response = try waitResponse(method: .POST, url: "/admin/posts") { request in
//            try request.setFormData(form, csrfToken: self.csrfToken)
//        }
//        
//        XCTAssertEqual(response.http.status, .seeOther)
//        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/admin/posts/1/edit")
//        XCTAssertEqual(try Post.query(on: conn).count().wait(), 1)
//        XCTAssertEqual(try Tag.query(on: conn).count().wait(), 3)
//    }
//    
//    func testCanUpdateAPost() throws {
//        
//        _ = try DataMaker.makePost(title: "beforeUpdate", isStatic: true, on: app, conn: conn).save(on: conn).wait()
//        
//        var response: Response!
//        
//        let form = try DataMaker.makePostFormForTest(title: "afterUpdate", content: "content", tags: "")
//        
//        response = try waitResponse(method: .POST, url: "/admin/posts/1/edit") { request in
//            try request.setFormData(form, csrfToken: self.csrfToken)
//        }
//        
//        XCTAssertEqual(response.http.status, .seeOther)
//        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/admin/posts/1/edit")
//        
//        response = try waitResponse(method: .GET, url: "/admin/posts/1/edit")
//        
//        XCTAssertEqual(response.http.status, .ok)
//        XCTAssertEqual(view.get("post.title")?.string, "afterUpdate")
//        XCTAssertEqual(try Post.query(on: conn).first().wait()?.title, "afterUpdate")
//    }
//    
//    func testCanAddTagsOnUpdate() throws {
//        
//        let tag = try DataMaker.makeTag("Swift").save(on: conn).wait()
//        let post = try DataMaker.makePost(title: "beforeUpdate", isStatic: true, on: app, conn: conn).save(on: conn).wait()
//        _ = try post.tags.attach(tag, on: conn).wait()
//        
//        var response: Response!
//        
//        response = try waitResponse(method: .GET, url: "/admin/posts/1/edit")
//        
//        XCTAssertEqual(response.http.status, .ok)
//        XCTAssertEqual(view.get("post.tags_string")?.string, "Swift")
//        
//        let form = try DataMaker.makePostFormForTest(title: "afterUpdate", content: "content", tags: "Swift,iOS")
//
//        response = try waitResponse(method: .POST, url: "/admin/posts/1/edit") { request in
//            try request.setFormData(form, csrfToken: self.csrfToken)
//        }
//        
//        XCTAssertEqual(response.http.status, .seeOther)
//        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/admin/posts/1/edit")
//        XCTAssertEqual(try Tag.query(on: conn).count().wait(), 2)
//        
//        response = try waitResponse(method: .GET, url: "/admin/posts/1/edit")
//        
//        XCTAssertEqual(response.http.status, .ok)
//        XCTAssertEqual(view.get("post.tags_string")?.string, "Swift,iOS")
//    }
//    
//    func testCanRefreshTagsOnUpdate() throws {
//        let tag1 = try DataMaker.makeTag("Swift").save(on: conn).wait()
//        let tag2 = try DataMaker.makeTag("Kotlin").save(on: conn).wait()
//        let post = try DataMaker.makePost(title: "beforeUpdate", isStatic: true, on: app, conn: conn).save(on: conn).wait()
//        _ = try post.tags.attach(tag1, on: conn).wait()
//        _ = try post.tags.attach(tag2, on: conn).wait()
//        
//        var response: Response!
//        
//        response = try waitResponse(method: .GET, url: "/admin/posts/1/edit")
//        
//        XCTAssertEqual(response.http.status, .ok)
//        XCTAssertEqual(view.get("post.tags_string")?.string, "Swift,Kotlin")
//        
//        let form = try DataMaker.makePostFormForTest(title: "afterUpdate", content: "content", tags: "iOS")
//        
//        response = try waitResponse(method: .POST, url: "/admin/posts/1/edit") { request in
//            try request.setFormData(form, csrfToken: self.csrfToken)
//        }
//        
//        XCTAssertEqual(response.http.status, .seeOther)
//        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/admin/posts/1/edit")
//        XCTAssertEqual(try Tag.query(on: conn).count().wait(), 3)
//        
//        response = try waitResponse(method: .GET, url: "/admin/posts/1/edit")
//        
//        XCTAssertEqual(response.http.status, .ok)
//        XCTAssertEqual(view.get("post.tags_string")?.string, "iOS")
//    }
//}
//
//extension AdminPostControllerTests {
//    public static let allTests = [
//        ("testCanViewIndex", testCanViewIndex),
//        ("testCanViewPageButtonAtTwoPages", testCanViewPageButtonAtTwoPages),
//        ("testCanViewPageButtonAtThreePages", testCanViewPageButtonAtThreePages),
//        ("testCanViewStaticContent", testCanViewStaticContent),
//        ("testCanViewCreateView", testCanViewCreateView),
//        ("testCanViewEditView", testCanViewEditView),
//        ("testCanDestroyPosts", testCanDestroyPosts),
//        ("testCanDestroyStaticContents", testCanDestroyStaticContents),
//        ("testCanStoreAPost", testCanStoreAPost),
//        ("testCanStoreAStaticPost", testCanStoreAStaticPost),
//        ("testCanStoreADraftPost", testCanStoreADraftPost),
//        ("testCannotStoreAPostHasInvalidCategory", testCannotStoreAPostHasInvalidCategory),
//        ("testCanStoreAPostHasNotInsertedTags", testCanStoreAPostHasNotInsertedTags),
//        ("testCanUpdateAPost", testCanUpdateAPost),
//        ("testCanAddTagsOnUpdate", testCanAddTagsOnUpdate),
//        ("testCanRefreshTagsOnUpdate", testCanRefreshTagsOnUpdate)
//    ]
//}
