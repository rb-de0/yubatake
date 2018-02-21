@testable import App
import HTTP
import Vapor
import XCTest

final class AdminTagControllerCSRFTests: ControllerTestCase {
    
    func testCanPreventCSRFOnDestroy() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        try DataMaker.makeTag("Swift").save()
        
        let json: JSON = ["tags": [1]]
        request = Request(method: .post, uri: "/admin/tags/delete")
        try request.setFormData(json, "")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .forbidden)
        XCTAssertEqual(try Tag.count(), 1)
    }
    
    func testCanPreventCSRFOnStore() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        let json = DataMaker.makeTagJSON(name: "Swift")
        
        request = Request(method: .post, uri: "/admin/tags")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, "")
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .forbidden)
        XCTAssertEqual(try Tag.count(), 0)
    }
    
    func testCanPreventCSRFOnUpdate() throws {
        
        let tag = try DataMaker.makeTag("Swift")
        try tag.save()
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        var json: JSON!
        
        json = DataMaker.makeTagJSON(name: "Kotlin")
        
        request = Request(method: .post, uri: "/admin/tags/1/edit")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, "")
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .forbidden)
        XCTAssertEqual(try Tag.find(1)?.name, "Swift")
    }
}

extension AdminTagControllerCSRFTests {
    
	public static var allTests = [
		("testCanPreventCSRFOnUpdate", testCanPreventCSRFOnUpdate),
		("testCanPreventCSRFOnDestroy", testCanPreventCSRFOnDestroy),
		("testCanPreventCSRFOnStore", testCanPreventCSRFOnStore)
    ]
}
