@testable import App
import HTTP
import Vapor
import XCTest

final class LoginControllerCSRFTests: ControllerTestCase {
    
    func testCanPreventCSRFOnLogin() throws {
        
        let hashedPassword = try resolve(HashProtocol.self).make("passwd").makeString()
        let user = User(name: "login", password: hashedPassword)
        try user.save()
        
        var request: Request!
        var response: Response!
        
        let json: JSON = ["name": "login"]
        request = Request(method: .post, uri: "/login")
        try request.setFormData(json, "")
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .forbidden)
        XCTAssertNil(response.headers[HeaderKey.setCookie])
    }
}
