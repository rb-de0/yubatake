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
}

extension AdminPostControllerMessageTests {
    
	public static var allTests = [
		("testCanViewValidateErrorOnStore", testCanViewValidateErrorOnStore),
		("testCanViewValidateErrorOnUpdate", testCanViewValidateErrorOnUpdate)
    ]
}
