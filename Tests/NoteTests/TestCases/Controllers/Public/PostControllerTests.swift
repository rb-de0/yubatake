@testable import App
import Fluent
import Vapor
import XCTest

final class PostControllerTests: ControllerTestCase {
    
    func testCanViewIndex() throws {
        
        var response: Response!
        
        response = try waitResponse(method: .GET, url: "/posts")
        
        XCTAssertEqual(response.http.status, .ok)
        
        response = try waitResponse(method: .GET, url: "/")
        
        XCTAssertEqual(response.http.status, .ok)
    }
    
    func testCanViewPageButtonAtOnePage() throws {
        
        try (1...10).forEach { _ in
            _ = try DataMaker.makePost(on: app, conn: conn).save(on: conn).wait()
        }
        
        XCTAssertEqual(try Post.query(on: conn).filter(\Post.isPublished == true).filter(\Post.isStatic == false).count().wait(), 10)
        
        var response: Response!
        
        response = try waitResponse(method: .GET, url: "/posts")
        
        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(view.get("page.position.max")?.int, 1)
        XCTAssertEqual(view.get("page.position.current")?.int, 1)
        XCTAssertNil(view.get("page.position.next"))
        XCTAssertNil(view.get("page.position.previous"))
        XCTAssertEqual(view.get("data")?.array?.count, 10)
    }
    
    func testCanViewPageButtonAtTwoPages() throws {
        
        try (1...11).forEach { _ in
            _ = try DataMaker.makePost(on: app, conn: conn).save(on: conn).wait()
        }
        
        XCTAssertEqual(try Post.query(on: conn).filter(\Post.isPublished == true).filter(\Post.isStatic == false).count().wait(), 11)
        
        var response: Response!
        
        response = try waitResponse(method: .GET, url: "/posts")
        
        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(view.get("page.position.max")?.int, 2)
        XCTAssertEqual(view.get("page.position.current")?.int, 1)
        XCTAssertEqual(view.get("page.position.next")?.int, 2)
        XCTAssertNil(view.get("page.position.previous"))
        XCTAssertEqual(view.get("data")?.array?.count, 10)
        
        response = try waitResponse(method: .GET, url: "/posts?page=2")
        
        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(view.get("page.position.current")?.int, 2)
        XCTAssertNil(view.get("page.position.next"))
        XCTAssertEqual(view.get("page.position.previous")?.int, 1)
        XCTAssertEqual(view.get("data")?.array?.count, 1)
    }
    
    func testCanViewPageButtonAtThreePages() throws {

        try (1...21).forEach { _ in
            _ = try DataMaker.makePost(on: app, conn: conn).save(on: conn).wait()
        }
        
        XCTAssertEqual(try Post.query(on: conn).filter(\Post.isPublished == true).filter(\Post.isStatic == false).count().wait(), 21)
        
        var response: Response!
        
        response = try waitResponse(method: .GET, url: "/posts?page=2")
        
        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(view.get("page.position.max")?.int, 3)
        XCTAssertEqual(view.get("page.position.current")?.int, 2)
        XCTAssertEqual(view.get("page.position.next")?.int, 3)
        XCTAssertEqual(view.get("page.position.previous")?.int, 1)
        XCTAssertEqual(view.get("data")?.array?.count, 10)
    }
    
    func testCanViewStaticContent() throws {
        
        _ = try DataMaker.makePost(isStatic: true, on: app, conn: conn).save(on: conn).wait()
        
        let response = try waitResponse(method: .GET, url: "/posts")
        
        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(view.get("data")?.array?.count, 0)
        XCTAssertEqual(view.get("static_contents")?.array?.count, 1)
    }
    
    func testCannotViewDraftContent() throws {
        
        _ = try DataMaker.makePost(isPublished: false, on: app, conn: conn).save(on: conn).wait()
        
        let response = try waitResponse(method: .GET, url: "/posts")
        
        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(view.get("data")?.array?.count, 0)
    }
    
    func testCanViewPostsInTags() throws {
        
        let tag = try DataMaker.makeTag("Swift").save(on: conn).wait()
        let post = try DataMaker.makePost(on: app, conn: conn).save(on: conn).wait()
        _ = try post.tags.attach(tag, on: conn).wait()
        
        var response: Response!
        
        response = try waitResponse(method: .GET, url: "/tags/1/posts")
        
        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(view.get("page.position.max")?.int, 1)
        XCTAssertEqual(view.get("data")?.array?.count, 1)
    }

    
    func testCanViewPostsInACategory() throws {
        
        let category = try DataMaker.makeCategory("Programming").save(on: conn).wait()
        _ = try DataMaker.makePost(categoryId: category.id, on: app, conn: conn).save(on: conn).wait()
        
        var response: Response!
        
        response = try waitResponse(method: .GET, url: "/categories/1/posts")
        
        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(view.get("page.position.max")?.int, 1)
        XCTAssertEqual(view.get("data")?.array?.count, 1)
    }
    
    func testCanViewPostsNoCategory() throws {
        
        _ = try DataMaker.makePost(on: app, conn: conn).save(on: conn).wait()
        
        var response: Response!
        
        response = try waitResponse(method: .GET, url: "/categories/noncategorized/posts")
        
        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(view.get("page.position.max")?.int, 1)
        XCTAssertEqual(view.get("data")?.array?.count, 1)
    }
    
    func testCanViewAPost() throws {
        
        _ = try DataMaker.makePost(on: app, conn: conn).save(on: conn).wait()
        
        var response: Response!
        
        response = try waitResponse(method: .GET, url: "/posts/1")
        
        XCTAssertEqual(response.http.status, .ok)
        
        response = try waitResponse(method: .GET, url: "/1")
        
        XCTAssertEqual(response.http.status, .ok)
    }
}

extension PostControllerTests {
    public static let allTests = [
        ("testCanViewIndex", testCanViewIndex),
        ("testCanViewPageButtonAtOnePage", testCanViewPageButtonAtOnePage),
        ("testCanViewPageButtonAtTwoPages", testCanViewPageButtonAtTwoPages),
        ("testCanViewPageButtonAtThreePages", testCanViewPageButtonAtThreePages),
        ("testCanViewStaticContent", testCanViewStaticContent),
        ("testCannotViewDraftContent", testCannotViewDraftContent),
        ("testCanViewPostsInTags", testCanViewPostsInTags),
        ("testCanViewPostsInACategory", testCanViewPostsInACategory),
        ("testCanViewPostsNoCategory", testCanViewPostsNoCategory),
        ("testCanViewAPost", testCanViewAPost)
    ]
}