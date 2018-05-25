@testable import App
import Vapor
import XCTest

final class AdminCategoryControllerCSRFTests: ControllerTestCase, AdminTestCase {
    
    func testCanPreventCSRFOnDestroy() throws {

        var response: Response!
        
        _ = try DataMaker.makeCategory("Programming").save(on: conn).wait()
        
        XCTAssertEqual(try App.Category.query(on: conn).count().wait(), 1)
        
        response = try waitResponse(method: .POST, url: "/admin/categories/delete") { request in
            try request.setFormData(["categories": [1]], csrfToken: "")
        }
        
        XCTAssertEqual(response.http.status, .forbidden)
        
        response = try waitResponse(method: .GET, url: "/admin/categories")
        
        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(try App.Category.query(on: conn).count().wait(), 1)
        XCTAssertEqual(view.get("data")?.array?.count, 1)
    }
    
    func testCanPreventCSRFOnStore() throws {
        
        var response: Response!
        
        let form = DataMaker.makeCategoryFormForTest("Programming")
        
        response = try waitResponse(method: .POST, url: "/admin/categories") { request in
            try request.setFormData(form, csrfToken: "")
        }
        
        XCTAssertEqual(response.http.status, .forbidden)
        
        response = try waitResponse(method: .GET, url: "/admin/categories")
        
        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(try App.Category.query(on: conn).count().wait(), 0)
        XCTAssertEqual(view.get("data")?.array?.count, 0)
    }
    
    func testCanPreventCSRFOnUpdate() throws {
        
        var response: Response!
        
        _ = try DataMaker.makeCategory("Programming").save(on: conn).wait()
        
        XCTAssertEqual(try App.Category.query(on: conn).first().wait()?.name, "Programming")
        
        let form = DataMaker.makeCategoryFormForTest("FX")
        
        response = try waitResponse(method: .POST, url: "/admin/categories/1/edit") { request in
            try request.setFormData(form, csrfToken: "")
        }
        
        XCTAssertEqual(response.http.status, .forbidden)
        XCTAssertEqual(try App.Category.query(on: conn).first().wait()?.name, "Programming")
    }
}

extension AdminCategoryControllerCSRFTests {
    public static let allTests = [
        ("testCanPreventCSRFOnDestroy", testCanPreventCSRFOnDestroy),
        ("testCanPreventCSRFOnStore", testCanPreventCSRFOnStore),
        ("testCanPreventCSRFOnUpdate", testCanPreventCSRFOnUpdate)
    ]
}