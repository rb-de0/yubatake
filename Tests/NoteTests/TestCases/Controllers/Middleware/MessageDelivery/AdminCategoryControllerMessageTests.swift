@testable import App
import Vapor
import XCTest

final class AdminCategoryControllerMessageTests: ControllerTestCase, AdminTestCase {
    
    func testCanViewValidateErrorOnStore() throws {
        
        var response: Response!
        
        let form = DataMaker.makeCategoryFormForTest("")
        
        response = try waitResponse(method: .POST, url: "/admin/categories") { request in
            try request.setFormData(form, csrfToken: self.csrfToken)
        }
        
        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/admin/categories/create")
        XCTAssertEqual(try App.Category.query(on: conn).count().wait(), 0)
        
        response = try waitResponse(method: .GET, url: "/admin/categories/create")
        
        XCTAssertEqual(view.get("name")?.string, "")
        XCTAssertNotNil(view.get("error_message"))
    }
    
    func testCanViewValidateErrorOnUpdate() throws {
        
        _ = try DataMaker.makeCategory("Programming").save(on: conn).wait()
        
        var response: Response!
        
        let name = String(repeating: "1", count: 33)
        let form = DataMaker.makeCategoryFormForTest(name)
        
        response = try waitResponse(method: .POST, url: "/admin/categories/1/edit") { request in
            try request.setFormData(form, csrfToken: self.csrfToken)
        }
        
        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/admin/categories/1/edit")
        
        response = try waitResponse(method: .GET, url: "/admin/categories/1/edit")
        
        XCTAssertNotNil(view.get("error_message"))
        XCTAssertEqual(view.get("name")?.string, name)
        XCTAssertEqual(try App.Category.query(on: conn).first().wait()?.name, "Programming")
    }
}

extension AdminCategoryControllerMessageTests {
    public static let allTests = [
        ("testCanViewValidateErrorOnStore", testCanViewValidateErrorOnStore),
        ("testCanViewValidateErrorOnUpdate", testCanViewValidateErrorOnUpdate)
    ]
}