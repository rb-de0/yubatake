@testable import App
import HTTP
import Vapor
import XCTest

final class PostControllerTests: ControllerTestCase {
    
    func testCanViewIndex() throws {
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/posts")
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        
        request = Request(method: .get, uri: "/")
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
    }

    func testCanViewPageButtonAtOnePage() throws {
        
        try (1...10).forEach { _ in
            try DataMaker.makePost().save()
        }
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/posts")
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(view.get("page.position.max"), 1)
        XCTAssertEqual(view.get("page.position.current"), 1)
        XCTAssertNil(view.get("page.position.next"))
        XCTAssertNil(view.get("page.position.previous"))
    }
    
    func testCanViewPageButtonAtTwoPages() throws {
        
        try (1...11).forEach { _ in
            try DataMaker.makePost().save()
        }
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/posts")
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(view.get("page.position.max"), 2)
        XCTAssertEqual(view.get("page.position.current"), 1)
        XCTAssertEqual(view.get("page.position.next"), 2)
        XCTAssertNil(view.get("page.position.previous"))
        
        request = Request(method: .get, uri: "/posts?page=2")
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(view.get("page.position.current"), 2)
        XCTAssertNil(view.get("page.position.next"))
        XCTAssertEqual(view.get("page.position.previous"), 1)
    }
    
    func testCanViewPageButtonAtThreePages() throws {
        
        try (1...21).forEach { _ in
            try DataMaker.makePost().save()
        }
        
        var request: Request!
        var response: Response!

        request = Request(method: .get, uri: "/posts?page=2")
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(view.get("page.position.max"), 3)
        XCTAssertEqual(view.get("page.position.current"), 2)
        XCTAssertEqual(view.get("page.position.next"), 3)
        XCTAssertEqual(view.get("page.position.previous"), 1)
    }
    
    func testCanViewStaticContent() throws {
        
        try DataMaker.makePost(isStatic: true).save()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/posts")
        response = try drop.respond(to: request)
        
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(view.get("page.position.max"), 0)
        XCTAssertEqual((view.get("data") as Node?)?.array?.count, 0)
        XCTAssertEqual((view.get("static_contents") as Node?)?.array?.count, 1)
    }
    
    func testCanViewPostsInTags() throws {
        let tag = try DataMaker.makeTag("test_tag")
        try tag.save()
        
        let post = try DataMaker.makePost()
        try post.save()
        try post.tags.add(tag)
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/tags/1/posts")
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(view.get("page.position.max"), 1)
        XCTAssertEqual((view.get("data") as Node?)?.array?.count, 1)
    }
    
    func testCanViewPostsInACategory() throws {
        let category = try DataMaker.makeCategory("test_category")
        try category.save()
        
        let post = try DataMaker.makePost(categoryId: category.id?.int)
        try post.save()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/categories/1/posts")
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(view.get("page.position.max"), 1)
        XCTAssertEqual((view.get("data") as Node?)?.array?.count, 1)
    }
    
    func testCanViewPostsNoCategory() throws {
        
        let post = try DataMaker.makePost()
        try post.save()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/categories/noncategorized/posts")
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(view.get("page.position.max"), 1)
        XCTAssertEqual((view.get("data") as Node?)?.array?.count, 1)
    }
    
    func testCanViewAPost() throws {
        
        let post = try DataMaker.makePost()
        try post.save()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/posts/1")
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
    }
}

extension PostControllerTests {
    
	public static var allTests = [
		("testCanViewPostsInTags", testCanViewPostsInTags),
		("testCanViewPageButtonAtTwoPages", testCanViewPageButtonAtTwoPages),
		("testCanViewPageButtonAtOnePage", testCanViewPageButtonAtOnePage),
		("testCanViewPostsNoCategory", testCanViewPostsNoCategory),
		("testCanViewAPost", testCanViewAPost),
		("testCanViewPageButtonAtThreePages", testCanViewPageButtonAtThreePages),
		("testCanViewStaticContent", testCanViewStaticContent),
		("testCanViewIndex", testCanViewIndex),
		("testCanViewPostsInACategory", testCanViewPostsInACategory)
    ]
}
