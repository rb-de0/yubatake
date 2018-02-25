@testable import App
import HTTP
import Vapor
import XCTest

final class AdminTagControllerMessageTests: ControllerTestCase {
    
    func testCanViewValidateErrorOnStore() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        let json = DataMaker.makeTagJSON(name: "")
        
        request = Request(method: .post, uri: "/admin/tags")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/admin/tags/create")
        XCTAssertEqual(try Tag.count(), 0)
        
        request = Request(method: .get, uri: "/admin/tags/create")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertNotNil(view.get("request.storage.error_message") as String?)
    }
    
    func testCanViewValidateErrorOnUpdate() throws {
        
        let tag = try DataMaker.makeTag("Swift")
        try tag.save()
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        var json: JSON!
        
        json = DataMaker.makeTagJSON(name: "")
        
        request = Request(method: .post, uri: "/admin/tags/1/edit")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/admin/tags/1/edit")
        XCTAssertEqual(try Tag.find(1)?.name, "Swift")
        
        request = Request(method: .get, uri: "/admin/tags/1/edit")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertNotNil(view.get("request.storage.error_message") as String?)
    }
    
    // MARK: - FormData
    
    func testCanDeliveryFormDataOnStore() throws {
        
        let requestData = try login()
        
        var request: Request!
        var json: JSON!
        
        json = DataMaker.makeTagJSON(name: String(repeating: "1", count: 17))
        
        request = Request(method: .post, uri: "/admin/tags")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, requestData.csrfToken)
        _ = try drop.respond(to: request)
        
        request = Request(method: .get, uri: "/admin/tags/create")
        request.cookies.insert(requestData.cookie)
        _ = try drop.respond(to: request)
        
        XCTAssertEqual(view.get("name"), String(repeating: "1", count: 17))
    }
    
    func testCanDelieryFormDataOnUpdate() throws {
        
        let requestData = try login()
        
        var request: Request!
        var json: JSON!
        
        try DataMaker.makeTag("iOS").save()
        
        json = DataMaker.makeTagJSON(name: String(repeating: "1", count: 17))
        
        request = Request(method: .post, uri: "/admin/tags/1/edit")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, requestData.csrfToken)
        _ = try drop.respond(to: request)
        
        request = Request(method: .get, uri: "/admin/tags/1/edit")
        request.cookies.insert(requestData.cookie)
        _ = try drop.respond(to: request)
        
        XCTAssertEqual(view.get("name"), String(repeating: "1", count: 17))
    }
}

extension AdminTagControllerMessageTests {
    public static let allTests = [
        ("testCanViewValidateErrorOnStore", testCanViewValidateErrorOnStore),
        ("testCanViewValidateErrorOnUpdate", testCanViewValidateErrorOnUpdate),
        ("testCanDeliveryFormDataOnStore", testCanDeliveryFormDataOnStore),
        ("testCanDelieryFormDataOnUpdate", testCanDelieryFormDataOnUpdate)
    ]
}