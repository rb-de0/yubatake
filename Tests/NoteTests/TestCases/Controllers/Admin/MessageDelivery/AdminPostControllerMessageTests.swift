@testable import App
import HTTP
import Vapor
import XCTest

final class AdminPostControllerMessageTests: ControllerTestCase {
    
    func testCanViewValidateErrorOnStore() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        var json: JSON!
        
        json = DataMaker.makePostJSON()
        try json.set("title", "")
        
        request = Request(method: .post, uri: "/admin/posts")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/admin/posts/create")
        XCTAssertEqual(try Post.count(), 0)
        
        request = Request(method: .get, uri: "/admin/posts/create")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertNotNil(view.get("request.storage.error_message") as String?)
    }
    
    func testCanViewValidateErrorOnUpdate() throws {
        
        let post = try DataMaker.makePost(title: "beforeUpdate")
        try post.save()
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        var json: JSON!
        
        json = DataMaker.makePostJSON()
        try json.set("title", "")
        
        request = Request(method: .post, uri: "/admin/posts/1/edit")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/admin/posts/1/edit")
        XCTAssertEqual(try Post.find(1)?.title, "beforeUpdate")
        
        request = Request(method: .get, uri: "/admin/posts/1/edit")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertNotNil(view.get("request.storage.error_message") as String?)
    }
    
    // MARK: - FormData
    
    func testCanDeliveryFormDataOnStore() throws {
        
        let requestData = try login()
        
        var request: Request!
        var json: JSON!
        
        try DataMaker.makeCategory("Programming").save()
        
        json = DataMaker.makePostJSON(title: "", content: "before_content", isStatic: true, categoryId: 1)
        
        request = Request(method: .post, uri: "/admin/posts")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, requestData.csrfToken)
        _ = try drop.respond(to: request)
        
        request = Request(method: .get, uri: "/admin/posts/create")
        request.cookies.insert(requestData.cookie)
        _ = try drop.respond(to: request)
        
        XCTAssertEqual(view.get("post.title"), "")
        XCTAssertEqual(view.get("post.content"), "before_content")
        XCTAssertEqual(view.get("post.is_static"), true)
        XCTAssertEqual(view.get("post.category.id"), 1)
        
        json = DataMaker.makePostJSON(title: "", content: "before_content", isStatic: true, categoryId: nil)
        
        request = Request(method: .post, uri: "/admin/posts")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, requestData.csrfToken)
        _ = try drop.respond(to: request)
        
        request = Request(method: .get, uri: "/admin/posts/create")
        request.cookies.insert(requestData.cookie)
        _ = try drop.respond(to: request)
        
        XCTAssertNil(view.get("post.category"))
    }
    
    func testCanDelieryFormDataOnUpdate() throws {
        
        let requestData = try login()
        
        var request: Request!
        var json: JSON!
        
        try DataMaker.makeCategory("Programming").save()
        try DataMaker.makePost(title: "before", content: "before_content", isStatic: true, categoryId: 1).save()
        
        json = DataMaker.makePostJSON(title: "", content: "before_content", isStatic: true, categoryId: 1)
        
        request = Request(method: .post, uri: "/admin/posts/1/edit")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, requestData.csrfToken)
        _ = try drop.respond(to: request)

        request = Request(method: .get, uri: "/admin/posts/1/edit")
        request.cookies.insert(requestData.cookie)
        _ = try drop.respond(to: request)
        
        XCTAssertEqual(view.get("post.title"), "")
        XCTAssertEqual(view.get("post.content"), "before_content")
        XCTAssertEqual(view.get("post.is_static"), true)
        XCTAssertEqual(view.get("post.category.id"), 1)
    }
}

extension AdminPostControllerMessageTests {
    public static let allTests = [
        ("testCanViewValidateErrorOnStore", testCanViewValidateErrorOnStore),
        ("testCanViewValidateErrorOnUpdate", testCanViewValidateErrorOnUpdate),
        ("testCanDeliveryFormDataOnStore", testCanDeliveryFormDataOnStore),
        ("testCanDelieryFormDataOnUpdate", testCanDelieryFormDataOnUpdate)
    ]
}