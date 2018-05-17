@testable import App
import Crypto
import Vapor
import XCTest

final class LoginControllerTests: ControllerTestCase {
    
    func testCanCreateRootUser() throws {
        
        let count = try User.query(on: conn).count().wait()
        let rootUser = try User.query(on: conn).all().wait().first
        
        XCTAssertEqual(count, 1)
        XCTAssertEqual(rootUser?.name, "root")
    }
    
    func testCanViewIndex() throws {
        let loginResponse = try waitResponse(method: .GET, url: "/login")
        XCTAssertEqual(loginResponse.http.status, .ok)
    }

    func testCanLogin() throws {
        
        let hassedPassword = try app.make(BCryptDigest.self).hash("passwd")
        let user = User(name: "login", password: hassedPassword)
        _ = try user.save(on: conn).wait()
        
        var response: Response
        
        response = try waitResponse(method: .POST, url: "/login") { request in
            try request.setFormData(["name": "login", "password": "passwd"], csrfToken: self.csrfToken)
        }
        
        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers.firstValue(name: .location), "admin/posts")
        
        response = try waitResponse(method: .GET, url: "/admin/posts")
        
        XCTAssertEqual(response.http.status, .ok)

        response = try waitResponse(method: .GET, url: "/logout")
        
        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers.firstValue(name: .location), "login")
        
        response = try waitResponse(method: .GET, url: "/admin/posts")
        
        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/login")
    }
    
    func testCannotLoginNoPassword() throws {

        let hassedPassword = try app.make(BCryptDigest.self).hash("passwd")
        let user = User(name: "login", password: hassedPassword)
        _ = try user.save(on: conn).wait()
        
        var response: Response!
        
        response = try waitResponse(method: .POST, url: "/login") { request in
            try request.setFormData(["name": "login", "password": ""], csrfToken: self.csrfToken)
        }
        
        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers.firstValue(name: .location), "login")
    }
}

extension LoginControllerTests {
    public static let allTests = [
        ("testCanCreateRootUser", testCanCreateRootUser),
        ("testCanViewIndex", testCanViewIndex),
        ("testCanLogin", testCanLogin),
        ("testCannotLoginNoPassword", testCannotLoginNoPassword)
    ]
}