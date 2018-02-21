@testable import App
import HTTP
import Vapor
import XCTest

final class AdminPostControllerCSRFTests: ControllerTestCase {
    
    func testCanPreventCSRFOnDestroy() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        try DataMaker.makePost().save()
        
        let json: JSON = ["posts": [1]]
        request = Request(method: .post, uri: "/admin/posts/delete")
        try request.setFormData(json, "")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .forbidden)
        XCTAssertEqual(try Post.count(), 1)
    }
    
    func testCanPreventCSRFOnStore() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        var json = DataMaker.makePostJSON()
        try json.set("tags", "Swift,iOS")
        
        request = Request(method: .post, uri: "/admin/posts")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, "")
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .forbidden)
        XCTAssertEqual(try Post.count(), 0)
    }
    
    func testCanPreventCSRFOnUpdate() throws {
        
        let post = try DataMaker.makePost(title: "beforeUpdate")
        try post.save()
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        var json: JSON!
        
        json = DataMaker.makePostJSON()
        try json.set("title", "afterUpdate")
        
        request = Request(method: .post, uri: "/admin/posts/1/edit")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, "")
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .forbidden)
        XCTAssertEqual(try Post.find(1)?.title, "beforeUpdate")
    }
}

extension AdminPostControllerCSRFTests {
    
	public static var allTests = [
		("testCanPreventCSRFOnUpdate", testCanPreventCSRFOnUpdate),
		("testCanPreventCSRFOnDestroy", testCanPreventCSRFOnDestroy),
		("testCanPreventCSRFOnStore", testCanPreventCSRFOnStore)
    ]
}
