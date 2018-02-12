@testable import App
import Cookies
import HTTP
import Vapor
import XCTest

final class LoginControllerTests: ControllerTestCase {
    
    func testCreateRootUser() throws {
        
        let count = try User.all().count
        let rootUser = try User.all().first
        
        XCTAssertEqual(count, 1)
        XCTAssertEqual(rootUser?.name, "root")
    }
    
    func testCanViewIndex() throws {
        
        let loginRequest = Request(method: .get, uri: "/login")
        let loginResponse = try drop.respond(to: loginRequest)
        
        XCTAssertEqual(loginResponse.status, .ok)
    }
    
    func testCanLogin() throws {
        
        let hashedPassword = try resolve(HashProtocol.self).make("passwd").makeString()
        let user = User(name: "login", password: hashedPassword)
        try user.save()
        
        var request: Request!
        var response: Response!
        
        let requestData = try getCSRFToken("/login")
        
        let json: JSON = ["name": "login", "password": "passwd"]
        request = Request(method: .post, uri: "/login")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, requestData.csrfToken)
        response = try drop.respond(to: request)

        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "admin/posts")
        XCTAssertNotNil(response.headers[HeaderKey.setCookie])

        request = Request(method: .get, uri: "/admin/posts")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        
        request = Request(method: .get, uri: "/login")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "admin/posts")
        
        request = Request(method: .get, uri: "/logout")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "login")
        
        request = Request(method: .get, uri: "/admin/posts")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/login")
    }
    
    func testCannotLoginNoPassword() throws {
        
        let hashedPassword = try resolve(HashProtocol.self).make("passwd").makeString()
        let user = User(name: "login", password: hashedPassword)
        try user.save()
        
        var request: Request!
        var response: Response!
        
        let requestData = try getCSRFToken("/login")
        
        let json: JSON = ["name": "login"]
        request = Request(method: .post, uri: "/login")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "login")
    }
}
