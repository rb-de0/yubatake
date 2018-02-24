@testable import App
import HTTP
import Vapor
import XCTest

final class AdminUserControllerCSRFTests: ControllerTestCase {
    
    func testCanPreventCSRFOnUpdate() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        let json: JSON = [
            "name": "rb_de0",
            "password": "123456789"
        ]
        
        request = Request(method: .post, uri: "/admin/user/edit")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, "")
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .forbidden)
        
        let count = try User.all().count
        let user = try User.all().last
        
        XCTAssertEqual(count, 2)
        XCTAssertEqual(user?.name, "login")
        XCTAssertEqual(user?.password, try resolve(HashProtocol.self).make("passwd").makeString())
    }
}

extension AdminUserControllerCSRFTests {
    public static let allTests = [
        ("testCanPreventCSRFOnUpdate", testCanPreventCSRFOnUpdate)
    ]
}