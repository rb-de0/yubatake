@testable import App
import HTTP
import Vapor
import XCTest

final class AdminCategoryControllerCSRFTests: ControllerTestCase {

    func testCanPreventCSRFOnDestroy() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        try DataMaker.makeCategory("Programming").save()
        
        let json: JSON = ["categories": [1]]
        request = Request(method: .post, uri: "/admin/categories/delete")
        try request.setFormData(json, "")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .forbidden)
        
        request = Request(method: .get, uri: "/admin/categories")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual((view.get("data") as Node?)?.array?.count, 1)
    }
    
    func testCanPreventCSRFOnStore() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        let json = DataMaker.makeCategoryJSON(name: "Programming")
        
        request = Request(method: .post, uri: "/admin/categories")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, "")
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .forbidden)
        XCTAssertEqual(try App.Category.count(), 0)
    }
    
    func testCanPreventCSRFOnUpdate() throws {
        
        let category = try DataMaker.makeCategory("Programming")
        try category.save()
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        var json: JSON!
        
        json = DataMaker.makeCategoryJSON(name: "FX")
        
        request = Request(method: .post, uri: "/admin/categories/1/edit")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, "")
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .forbidden)
        
        request = Request(method: .get, uri: "/admin/categories/1/edit")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(view.get("name"), "Programming")
    }
}

extension AdminCategoryControllerCSRFTests {
    
	public static var allTests = [
		("testCanPreventCSRFOnUpdate", testCanPreventCSRFOnUpdate),
		("testCanPreventCSRFOnDestroy", testCanPreventCSRFOnDestroy),
		("testCanPreventCSRFOnStore", testCanPreventCSRFOnStore)
    ]
}
