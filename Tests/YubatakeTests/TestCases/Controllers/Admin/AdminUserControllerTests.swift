//@testable import App
//import Crypto
//import Vapor
//import XCTest
//
//final class AdminUserControllerTests: ControllerTestCase, AdminTestCase {
//    
//    func testCanViewCreateView() throws {
//
//        var response: Response!
//        
//        response = try waitResponse(method: .GET, url: "/admin/user/edit")
//
//        XCTAssertEqual(response.http.status, .ok)
//        XCTAssertEqual(view.get("name")?.string, "root")
//        XCTAssertNil(view.get("password"))
//    }
//    
//    func testCanUpdateAUser() throws {
//        
//        let hash = try app.make(BCryptDigest.self)
//        var response: Response!
//        
//        let form = ["name": "rb_de0", "password": "123456789"]
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
//        let user = try User.query(on: conn).all().wait().first
//        XCTAssertEqual(view.get("name")?.string, "rb_de0")
//        XCTAssertEqual(user?.name, "rb_de0")
//        XCTAssert(try hash.verify("123456789", created: user?.password ?? ""))
//    }
//}
//
//extension AdminUserControllerTests {
//    public static let allTests = [
//        ("testCanViewCreateView", testCanViewCreateView),
//        ("testCanUpdateAUser", testCanUpdateAUser)
//    ]
//}
