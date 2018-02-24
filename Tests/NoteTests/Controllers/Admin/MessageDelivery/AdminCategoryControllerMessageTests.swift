@testable import App
import HTTP
import Vapor
import XCTest

final class AdminCategoryControllerMessageTests: ControllerTestCase {
    
    func testCanViewValidateErrorOnStore() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        var json: JSON!
        
        json = DataMaker.makeCategoryJSON(name: "")
        
        request = Request(method: .post, uri: "/admin/categories")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/admin/categories/create")
        XCTAssertEqual(try App.Category.count(), 0)
        
        request = Request(method: .get, uri: "/admin/categories/create")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertNotNil(view.get("request.storage.error_message") as String?)
    }
    
    func testCanViewValidateErrorOnUpdate() throws {
        
        let category = try DataMaker.makeCategory("Programming")
        try category.save()
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        var json: JSON!
        
        json = DataMaker.makeCategoryJSON(name: "")
        
        request = Request(method: .post, uri: "/admin/categories/1/edit")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/admin/categories/1/edit")
        XCTAssertEqual(try Category.find(1)?.name, "Programming")
        
        request = Request(method: .get, uri: "/admin/categories/1/edit")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertNotNil(view.get("request.storage.error_message") as String?)
    }
}

extension AdminCategoryControllerMessageTests {
    public static let allTests = [
        ("testCanViewValidateErrorOnStore", testCanViewValidateErrorOnStore),
        ("testCanViewValidateErrorOnUpdate", testCanViewValidateErrorOnUpdate)
    ]
}