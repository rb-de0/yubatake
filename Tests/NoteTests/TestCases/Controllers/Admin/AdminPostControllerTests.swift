@testable import App
import HTTP
import Vapor
import XCTest

final class AdminPostControllerTests: ControllerTestCase {
    
    func testCanViewIndex() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/admin/posts")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        
        try DataMaker.makePost().save()
        
        request = Request(method: .get, uri: "/admin/posts")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        
        XCTAssertEqual(view.get("page.position.max"), 1)
        XCTAssertEqual(view.get("page.position.current"), 1)
        XCTAssertNil(view.get("page.position.next"))
        XCTAssertNil(view.get("page.position.previous"))
        XCTAssertEqual((view.get("data") as Node?)?.array?.count, 1)
    }

    func testCanViewPageButtonAtOnePage() throws {
        
        let requestData = try login()
        
        try (1...10).forEach { _ in
            try DataMaker.makePost().save()
        }
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/admin/posts")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(view.get("page.position.max"), 1)
        XCTAssertEqual(view.get("page.position.current"), 1)
        XCTAssertNil(view.get("page.position.next"))
        XCTAssertNil(view.get("page.position.previous"))
    }
    
    func testCanViewPageButtonAtTwoPages() throws {
        
        let requestData = try login()
        
        try (1...11).forEach { _ in
            try DataMaker.makePost().save()
        }
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/admin/posts")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(view.get("page.position.max"), 2)
        XCTAssertEqual(view.get("page.position.current"), 1)
        XCTAssertEqual(view.get("page.position.next"), 2)
        XCTAssertNil(view.get("page.position.previous"))
        
        request = Request(method: .get, uri: "/posts?page=2")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(view.get("page.position.current"), 2)
        XCTAssertNil(view.get("page.position.next"))
        XCTAssertEqual(view.get("page.position.previous"), 1)
    }
    
    func testCanViewPageButtonAtThreePages() throws {
        
        let requestData = try login()
        
        try (1...21).forEach { _ in
            try DataMaker.makePost().save()
        }
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/admin/posts?page=2")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(view.get("page.position.max"), 3)
        XCTAssertEqual(view.get("page.position.current"), 2)
        XCTAssertEqual(view.get("page.position.next"), 3)
        XCTAssertEqual(view.get("page.position.previous"), 1)
    }
    
    func testCanViewStaticContent() throws {
        
        let requestData = try login()
        
        try DataMaker.makePost(isStatic: true).save()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/admin/static-contents")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(view.get("page.position.max"), 1)
        XCTAssertEqual((view.get("data") as Node?)?.array?.count, 1)
    }
    
    func testCanViewCreateView() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/admin/posts/create")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
    }
    
    func testCanViewEditView() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/admin/posts/1/edit")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .notFound)
        
        try DataMaker.makePost().save()
        
        request = Request(method: .get, uri: "/admin/posts/1/edit")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
    }
    
    func testCanDestroyPosts() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        try DataMaker.makePost().save()
        
        request = Request(method: .get, uri: "/admin/posts")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual((view.get("data") as Node?)?.array?.count, 1)
        
        let json: JSON = ["posts": [1]]
        request = Request(method: .post, uri: "/admin/posts/delete")
        try request.setFormData(json, requestData.csrfToken)
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/admin/posts")
        
        request = Request(method: .get, uri: "/admin/posts")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual((view.get("data") as Node?)?.array?.count, 0)
    }
    
    func testCanDestroyStaticContents() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        try DataMaker.makePost(isStatic: true).save()
        
        request = Request(method: .get, uri: "/admin/static-contents")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual((view.get("data") as Node?)?.array?.count, 1)
        
        let json: JSON = ["posts": [1]]
        request = Request(method: .post, uri: "/admin/posts/delete")
        try request.setFormData(json, requestData.csrfToken)
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/admin/static-contents")
        
        request = Request(method: .get, uri: "/admin/static-contents")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual((view.get("data") as Node?)?.array?.count, 0)
    }
    
    // MARK: - Store/Update
    
    func testCanStoreAPost() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        var json = DataMaker.makePostJSON()
        try json.set("tags", "Swift,iOS")
        
        request = Request(method: .post, uri: "/admin/posts")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/admin/posts/1/edit")
        XCTAssertEqual(try Post.count(), 1)
        XCTAssertEqual(try Tag.count(), 2)
        
        request = Request(method: .get, uri: "/admin/posts/1/edit")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(view.get("post.tags_string"), "Swift,iOS")
        XCTAssertEqual(try view.context?["tags"]?.array?.flatMap { try $0.get("name") } ?? [], ["Swift", "iOS"])
    }

    func testCannotStoreAPostHasInvalidCategory() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        var json = DataMaker.makePostJSON()
        try json.set("category", 10)
        
        request = Request(method: .post, uri: "/admin/posts")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/admin/posts/create")
        XCTAssertEqual(try Post.count(), 0)
    }
    
    func testCanStoreAPostHasNotInsertedTags() throws {
        
        try DataMaker.makeTag("Swift").save()
        try DataMaker.makeTag("iOS").save()
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        var json: JSON!

        XCTAssertEqual(try Tag.count(), 2)
        
        json = DataMaker.makePostJSON()
        try json.set("tags", "Vapor")
        
        request = Request(method: .post, uri: "/admin/posts")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/admin/posts/1/edit")
        XCTAssertEqual(try Post.count(), 1)
        XCTAssertEqual(try Tag.count(), 3)
    }
    
    func testCanUpdateAPost() throws {
        
        let post = try DataMaker.makePost(title: "beforeUpdate")
        try post.save()
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        var json: JSON!
        
        request = Request(method: .get, uri: "/posts/1")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(view.get("title"), "beforeUpdate")
        
        json = DataMaker.makePostJSON()
        try json.set("title", "afterUpdate")
        
        request = Request(method: .post, uri: "/admin/posts/1/edit")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/admin/posts/1/edit")
        
        request = Request(method: .get, uri: "/posts/1")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(view.get("title"), "afterUpdate")
    }
    
    func testCanAddTagsOnUpdate() throws {
        
        let tag = try DataMaker.makeTag("Swift")
        try tag.save()
        
        let post = try DataMaker.makePost(title: "beforeUpdate")
        try post.save()
        try post.tags.add(tag)
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        var json: JSON!
        
        request = Request(method: .get, uri: "/admin/posts/1/edit")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(view.get("post.tags_string"), "Swift")
        
        json = DataMaker.makePostJSON()
        try json.set("tags", "Swift,iOS")
        
        request = Request(method: .post, uri: "/admin/posts/1/edit")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/admin/posts/1/edit")
        XCTAssertEqual(try Tag.count(), 2)
    }
}

extension AdminPostControllerTests {
    public static let allTests = [
        ("testCanViewIndex", testCanViewIndex),
        ("testCanViewPageButtonAtOnePage", testCanViewPageButtonAtOnePage),
        ("testCanViewPageButtonAtTwoPages", testCanViewPageButtonAtTwoPages),
        ("testCanViewPageButtonAtThreePages", testCanViewPageButtonAtThreePages),
        ("testCanViewStaticContent", testCanViewStaticContent),
        ("testCanViewCreateView", testCanViewCreateView),
        ("testCanViewEditView", testCanViewEditView),
        ("testCanDestroyPosts", testCanDestroyPosts),
        ("testCanDestroyStaticContents", testCanDestroyStaticContents),
        ("testCanStoreAPost", testCanStoreAPost),
        ("testCannotStoreAPostHasInvalidCategory", testCannotStoreAPostHasInvalidCategory),
        ("testCanStoreAPostHasNotInsertedTags", testCanStoreAPostHasNotInsertedTags),
        ("testCanUpdateAPost", testCanUpdateAPost),
        ("testCanAddTagsOnUpdate", testCanAddTagsOnUpdate)
    ]
}