@testable import App
import HTTP
import Vapor
import XCTest

final class AdminUserControllerMessageTests: ControllerTestCase {
    
    func testCanViewValidateErrorOnUpdate() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        let json: JSON = [
            "name": "rb_de0",
            "password": ""
        ]
        
        request = Request(method: .post, uri: "/admin/user/edit")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/admin/user/edit")
        
        let count = try User.all().count
        let user = try User.all().last
        
        XCTAssertEqual(count, 2)
        XCTAssertEqual(user?.name, "login")
        XCTAssertEqual(user?.password, try resolve(HashProtocol.self).make("passwd").makeString())
        
        request = Request(method: .get, uri: "/admin/user/edit")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertNotNil(view.get("request.storage.error_message") as String?)
    }
}

extension AdminUserControllerMessageTests {
    
	public static var allTests = [
		("testCanViewValidateErrorOnUpdate", testCanViewValidateErrorOnUpdate)
    ]
}
