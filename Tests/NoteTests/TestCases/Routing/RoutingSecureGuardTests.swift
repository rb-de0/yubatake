@testable import App
import Cookies
import HTTP
import Vapor
import XCTest

final class RoutingSecureGuardTests: ControllerTestCase {
    
    private var token = ""
    
    override func setUp() {
        super.setUp()
        token = try! login().csrfToken
    }
    
    func testCanGuardRequest() throws {
        
        // Posts
        canGuard(method: .get, uri: "/admin/posts")
        canGuard(method: .get, uri: "/admin/posts/create")
        canGuard(method: .get, uri: "/admin/posts/1/edit")
        canGuard(method: .post, uri: "/admin/posts")
        canGuard(method: .post, uri: "/admin/posts/1/edit")
        canGuard(method: .post, uri: "/admin/posts/delete")
        
        // Tags
        canGuard(method: .get, uri: "/admin/tags")
        canGuard(method: .get, uri: "/admin/tags/create")
        canGuard(method: .get, uri: "/admin/tags/1/edit")
        canGuard(method: .post, uri: "/admin/tags")
        canGuard(method: .post, uri: "/admin/tags/1/edit")
        canGuard(method: .post, uri: "/admin/tags/delete")
        
        // Categories
        canGuard(method: .get, uri: "/admin/categories")
        canGuard(method: .get, uri: "/admin/categories/create")
        canGuard(method: .get, uri: "/admin/categories/1/edit")
        canGuard(method: .post, uri: "/admin/categories")
        canGuard(method: .post, uri: "/admin/categories/1/edit")
        canGuard(method: .post, uri: "/admin/categories/delete")
        
        // Images
        canGuard(method: .get, uri: "/admin/images")
        canGuard(method: .get, uri: "/admin/images/1/edit")
        canGuard(method: .post, uri: "/admin/images/1/edit")
        canGuard(method: .post, uri: "/admin/images/delete")
        canGuard(method: .post, uri: "/admin/images/cleanup")
        
        // Files
        canGuard(method: .get, uri: "/admin/files")
        canGuard(method: .get, uri: "/admin/static-contents")
        
        // SiteInfo
        canGuard(method: .get, uri: "/admin/siteinfo/edit")
        canGuard(method: .post, uri: "/admin/siteinfo/edit")
        
        // User
        canGuard(method: .get, uri: "/admin/user/edit")
        canGuard(method: .post, uri: "/admin/user/edit")
    }
    
    func testCanGuardAPIRequest() throws {
        
        canGuardAPI(method: .post, uri: "/api/converted_markdown")
        canGuardAPI(method: .get, uri: "/api/files")
        canGuardAPI(method: .get, uri: "/api/filebody")
        canGuardAPI(method: .post, uri: "/api/filebody")
        canGuardAPI(method: .post, uri: "/api/filebody/delete")
        canGuardAPI(method: .get, uri: "/api/images")
        canGuardAPI(method: .post, uri: "/api/images")
    }
    
    private func canGuard(method: HTTP.Method, uri: String) {

        do {
            let request = Request(method: method, uri: uri)
            try request.setFormData([:], token)
            let response = try drop.respond(to: request)
        
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers[HeaderKey.location], "/login")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    private func canGuardAPI(method: HTTP.Method, uri: String) {
        
        do {
            let request = Request(method: method, uri: uri)
            try request.setFormData([:], token)
            let response = try drop.respond(to: request)
            
            XCTAssertEqual(response.status, .unauthorized)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}

extension RoutingSecureGuardTests {
    public static let allTests = [
        ("testCanGuardRequest", testCanGuardRequest),
        ("testCanGuardAPIRequest", testCanGuardAPIRequest)
    ]
}