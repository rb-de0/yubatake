@testable import App
import Vapor
import XCTest

final class AdminTagControllerMessageTests: ControllerTestCase, AdminTestCase {
    
    func testCanViewValidateErrorOnStore() throws {
        
        var response: Response!
        
        let form = DataMaker.makeTagFormForTest("")
        
        response = try waitResponse(method: .POST, url: "/admin/tags") { request in
            try request.setFormData(form, csrfToken: self.csrfToken)
        }
        
        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/admin/tags/create")
        
        response = try waitResponse(method: .GET, url: "/admin/tags/create")
        
        XCTAssertEqual(view.get("name")?.string, "")
        XCTAssertNotNil(view.get("error_message"))
    }
    
    func testCanViewValidateErrorOnUpdate() throws {
        
        var response: Response!
        
        _ = try DataMaker.makeTag("Swift").save(on: conn).wait()
        
        let name = String(repeating: "1", count: 17)
        let form = DataMaker.makeCategoryFormForTest(name)
        
        response = try waitResponse(method: .POST, url: "/admin/tags/1/edit") { request in
            try request.setFormData(form, csrfToken: self.csrfToken)
        }
        
        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/admin/tags/1/edit")
        
        response = try waitResponse(method: .GET, url: "/admin/tags/1/edit")
        
        XCTAssertNotNil(view.get("error_message"))
        XCTAssertEqual(view.get("name")?.string, name)
        XCTAssertEqual(try Tag.query(on: conn).first().wait()?.name, "Swift")
    }
}

extension AdminTagControllerMessageTests {
    public static let allTests = [
        ("testCanViewValidateErrorOnStore", testCanViewValidateErrorOnStore),
        ("testCanViewValidateErrorOnUpdate", testCanViewValidateErrorOnUpdate)
    ]
}