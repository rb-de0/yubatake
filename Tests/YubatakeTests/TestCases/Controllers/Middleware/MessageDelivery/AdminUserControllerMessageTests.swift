//@testable import App
//import Vapor
//import XCTest
//
//final class AdminUserControllerMessageTests: ControllerTestCase, AdminTestCase {
//    
//    func testCanViewValidateErrorOnUpdate() throws {
//        
//        var response: Response!
//        var form: [String: String]
//        var user: User?
//        
//        form = ["name": "", "password": "123456789"]
//        
//        response = try waitResponse(method: .POST, url: "/admin/user/edit") { request in
//            try request.setFormData(form, csrfToken: self.csrfToken)
//        }
//        
//        XCTAssertEqual(response.http.status, .seeOther)
//        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/admin/user/edit")
//        
//        response = try waitResponse(method: .GET, url: "/admin/user/edit")
//        
//        user = try User.query(on: conn).all().wait().first
//        XCTAssertEqual(view.get("name")?.string, "")
//        XCTAssertEqual(user?.name, "root")
//        
//        let name = String(repeating: "1", count: 33)
//        form = ["name": name, "password": "123456789"]
//        
//        response = try waitResponse(method: .POST, url: "/admin/user/edit") { request in
//            try request.setFormData(form, csrfToken: self.csrfToken)
//        }
//        
//        XCTAssertEqual(response.http.status, .seeOther)
//        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/admin/user/edit")
//        
//        response = try waitResponse(method: .GET, url: "/admin/user/edit")
//        
//        user = try User.query(on: conn).all().wait().first
//        XCTAssertEqual(view.get("name")?.string, name)
//        XCTAssertEqual(user?.name, "root")
//        
//
//    }
//}
//
//extension AdminUserControllerMessageTests {
//    public static let allTests = [
//        ("testCanViewValidateErrorOnUpdate", testCanViewValidateErrorOnUpdate)
//    ]
//}
