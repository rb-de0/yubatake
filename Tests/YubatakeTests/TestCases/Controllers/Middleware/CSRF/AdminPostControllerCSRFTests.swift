//@testable import App
//import Vapor
//import XCTest
//
//final class AdminPostControllerCSRFTests: ControllerTestCase, AdminTestCase {
//    
//    func testCanPreventCSRFOnDestroy() throws {
//        
//        var response: Response!
//        
//        _ = try DataMaker.makePost(on: app, conn: conn).save(on: conn).wait()
//        
//        response = try waitResponse(method: .POST, url: "/admin/posts/delete") { request in
//            try request.setFormData(["posts": [1]], csrfToken: "")
//        }
//        
//        XCTAssertEqual(response.http.status, .forbidden)
//        
//        response = try waitResponse(method: .GET, url: "/admin/posts")
//        
//        XCTAssertEqual(response.http.status, .ok)
//        XCTAssertEqual(view.get("data")?.array?.count, 1)
//    }
//    
//    func testCanPreventCSRFOnStore() throws {
//        
//        var response: Response!
//        
//        let form = try DataMaker.makePostFormForTest(title: "title", content: "content", tags: "Swift,iOS")
//        
//        response = try waitResponse(method: .POST, url: "/admin/posts") { request in
//            try request.setFormData(form, csrfToken: "")
//        }
//        
//        XCTAssertEqual(response.http.status, .forbidden)
//        XCTAssertEqual(try Post.query(on: conn).count().wait(), 0)
//        XCTAssertEqual(try Tag.query(on: conn).count().wait(), 0)
//    }
//    
//    func testCanPreventCSRFOnUpdate() throws {
//        
//        _ = try DataMaker.makePost(title: "beforeUpdate", isStatic: true, on: app, conn: conn).save(on: conn).wait()
//        
//        var response: Response!
//        
//        response = try waitResponse(method: .GET, url: "/admin/posts/1/edit")
//        
//        XCTAssertEqual(response.http.status, .ok)
//        XCTAssertEqual(view.get("post.title")?.string, "beforeUpdate")
//        
//        let form = try DataMaker.makePostFormForTest(title: "afterUpdate", content: "content", tags: "")
//        
//        response = try waitResponse(method: .POST, url: "/admin/posts/1/edit") { request in
//            try request.setFormData(form, csrfToken: "")
//        }
//        
//        XCTAssertEqual(response.http.status, .forbidden)
//        
//        response = try waitResponse(method: .GET, url: "/admin/posts/1/edit")
//        
//        XCTAssertEqual(response.http.status, .ok)
//        XCTAssertEqual(view.get("post.title")?.string, "beforeUpdate")
//    }
//}
//
//extension AdminPostControllerCSRFTests {
//    public static let allTests = [
//        ("testCanPreventCSRFOnDestroy", testCanPreventCSRFOnDestroy),
//        ("testCanPreventCSRFOnStore", testCanPreventCSRFOnStore),
//        ("testCanPreventCSRFOnUpdate", testCanPreventCSRFOnUpdate)
//    ]
//}
