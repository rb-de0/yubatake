@testable import App
import HTTP
import Vapor
import XCTest

final class AdminUserControllerTests: ControllerTestCase {
    
    func testCanViewCreateView() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/admin/user/edit")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
    }
    
    func testCanUpdateAUser() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        let json: JSON = [
            "name": "rb_de0",
            "password": "123456789"
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
        XCTAssertEqual(user?.name, "rb_de0")
        XCTAssertEqual(user?.password, try resolve(HashProtocol.self).make("123456789").makeString())
    }
}

extension AdminUserControllerTests {
    public static let allTests = [
        ("testCanViewCreateView", testCanViewCreateView),
        ("testCanUpdateAUser", testCanUpdateAUser)
    ]
}