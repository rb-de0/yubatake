//@testable import App
//import Vapor
//import XCTest
//
//final class AdminUserControllerCSRFTests: ControllerTestCase, AdminTestCase {
//    
//    func testCanPreventCSRFOnUpdate() throws {
//        
//        var response: Response!
//        
//        let form = ["name": "rb_de0", "password": "123456789"]
//        
//        response = try waitResponse(method: .POST, url: "/admin/user/edit") { request in
//            try request.setFormData(form, csrfToken: "")
//        }
//        
//        XCTAssertEqual(response.http.status, .forbidden)
//        
//        let user = try User.query(on: conn).all().wait().first
//        
//        XCTAssertEqual(user?.name, "root")
//    }
//}
//
//extension AdminUserControllerCSRFTests {
//    public static let allTests = [
//        ("testCanPreventCSRFOnUpdate", testCanPreventCSRFOnUpdate)
//    ]
//}
