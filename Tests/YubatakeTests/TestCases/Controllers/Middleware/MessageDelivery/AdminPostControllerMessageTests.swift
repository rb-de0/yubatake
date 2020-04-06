//@testable import App
//import Vapor
//import XCTest
//
//final class AdminPostControllerMessageTests: ControllerTestCase, AdminTestCase {
//    
//    func testCanViewValidateErrorOnStore() throws {
//        
//        var response: Response!
//        
//        let form = try DataMaker.makePostFormForTest(title: "", content: "", tags: "")
//        
//        response = try waitResponse(method: .POST, url: "/admin/posts") { request in
//            try request.setFormData(form, csrfToken: self.csrfToken)
//        }
//        
//        XCTAssertEqual(response.http.status, .seeOther)
//        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/admin/posts/create")
//        XCTAssertEqual(try Post.query(on: conn).count().wait(), 0)
//        
//        response = try waitResponse(method: .GET, url: "/admin/posts/create")
//        
//        XCTAssertEqual(view.get("post.title")?.string, "")
//        XCTAssertEqual(view.get("post.content")?.string, "")
//        XCTAssertEqual(view.get("post.is_static")?.bool, false)
//        XCTAssertEqual(view.get("post.is_published")?.bool, true)
//        XCTAssertNotNil(view.get("error_message"))
//    }
//    
//    func testCanViewValidateErrorOnUpdate() throws {
//        
//        _ = try DataMaker.makeCategory("Programming").save(on: conn).wait()
//        _ = try DataMaker.makePost(title: "beforeUpdate", isStatic: true, on: app, conn: conn).save(on: conn).wait()
//        
//        var response: Response!
//        var post: Post?
//        
//        let title = String(repeating: "1", count: 129)
//        let content = String(repeating: "1", count: 8193)
//        let form = try DataMaker.makePostFormForTest(title: title, content: content, categoryId: 1, tags: "iOS,Swift")
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
//        post = try Post.query(on: conn).first().wait()
//        XCTAssertEqual(view.get("post.title")?.string, title)
//        XCTAssertEqual(view.get("post.content")?.string, content)
//        XCTAssertEqual(view.get("post.is_static")?.bool, false)
//        XCTAssertEqual(view.get("post.is_published")?.bool, true)
//        XCTAssertEqual(view.get("post.tags_string")?.string, "iOS,Swift")
//        XCTAssertEqual(view.get("post.category.id")?.int, 1)
//        XCTAssertNotNil(view.get("error_message"))
//        XCTAssertEqual(post?.title, "beforeUpdate")
//        XCTAssertEqual(post?.content, "content")
//        XCTAssertEqual(post?.isStatic, true)
//        XCTAssertNil(post?.categoryId)
//    }
//}
//
//extension AdminPostControllerMessageTests {
//    public static let allTests = [
//        ("testCanViewValidateErrorOnStore", testCanViewValidateErrorOnStore),
//        ("testCanViewValidateErrorOnUpdate", testCanViewValidateErrorOnUpdate)
//    ]
//}
