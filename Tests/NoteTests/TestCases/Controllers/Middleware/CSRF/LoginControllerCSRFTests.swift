@testable import App
import Crypto
import Vapor
import XCTest

final class LoginControllerCSRFTests: ControllerTestCase {
    
    func testCanPreventCSRFOnLogin() throws {
        
        let hassedPassword = try app.make(BCryptDigest.self).hash("passwd")
        let user = User(name: "login", password: hassedPassword)
        _ = try user.save(on: conn).wait()
        
        var response: Response
        
        response = try waitResponse(method: .POST, url: "/login") { request in
            try request.setFormData(["name": "login", "password": "passwd"], csrfToken: "")
        }
        
        XCTAssertEqual(response.http.status, .forbidden)
        XCTAssertNil(response.http.headers.firstValue(name: .setCookie))
    }
}

extension LoginControllerCSRFTests {
    public static let allTests = [
        ("testCanPreventCSRFOnLogin", testCanPreventCSRFOnLogin)
    ]
}