@testable import App
import Vapor
import XCTest

final class RoutingSecureGuardTests: ControllerTestCase {
    
    func testCanGuardRequest() throws {
        
        try canGuard(method: .GET, uri: "/admin/posts")
        try canGuard(method: .GET, uri: "/admin/posts/create")
        try canGuard(method: .GET, uri: "/admin/posts/1/edit")
        try canGuard(method: .POST, uri: "/admin/posts")
        try canGuard(method: .POST, uri: "/admin/posts/1/edit")
        try canGuard(method: .POST, uri: "/admin/posts/delete")
        
        // Tags
        try canGuard(method: .GET, uri: "/admin/tags")
        try canGuard(method: .GET, uri: "/admin/tags/create")
        try canGuard(method: .GET, uri: "/admin/tags/1/edit")
        try canGuard(method: .POST, uri: "/admin/tags")
        try canGuard(method: .POST, uri: "/admin/tags/1/edit")
        try canGuard(method: .POST, uri: "/admin/tags/delete")
        
        // Categories
        try canGuard(method: .GET, uri: "/admin/categories")
        try canGuard(method: .GET, uri: "/admin/categories/create")
        try canGuard(method: .GET, uri: "/admin/categories/1/edit")
        try canGuard(method: .POST, uri: "/admin/categories")
        try canGuard(method: .POST, uri: "/admin/categories/1/edit")
        try canGuard(method: .POST, uri: "/admin/categories/delete")
        
        // Images
        try canGuard(method: .GET, uri: "/admin/images")
        try canGuard(method: .GET, uri: "/admin/images/1/edit")
        try canGuard(method: .POST, uri: "/admin/images/1/edit")
        try canGuard(method: .POST, uri: "/admin/images/1/delete")
        try canGuard(method: .POST, uri: "/admin/images/cleanup")
        
        // Themes
        try canGuard(method: .GET, uri: "/admin/themes")
        
        // Files
        try canGuard(method: .GET, uri: "/admin/static-contents")
        
        // SiteInfo
        try canGuard(method: .GET, uri: "/admin/siteinfo/edit")
        try canGuard(method: .POST, uri: "/admin/siteinfo/edit")
        
        // User
        try canGuard(method: .GET, uri: "/admin/user/edit")
        try canGuard(method: .POST, uri: "/admin/user/edit")
    }
    
    func testCanGuardAPIRequest() throws {
        
        // Images
        try canGuardAPI(method: .GET, uri: "/api/images")
        try canGuardAPI(method: .POST, uri: "/api/images")
        
        // Files
        try canGuardAPI(method: .GET, uri: "/api/themes/default/files")
        try canGuardAPI(method: .GET, uri: "/api/files")
        try canGuardAPI(method: .POST, uri: "/api/files")
        
        // Themes
        try canGuardAPI(method: .GET, uri: "/api/themes")
        try canGuardAPI(method: .POST, uri: "/api/themes")
    }
    
    private func canGuard(method: HTTPMethod, uri: String) throws {
        
        let message = "\(method): \(uri)"
        
        do {
            let response = try waitResponse(method: method, url: uri) { request in
                try request.setFormData([String: String](), csrfToken: self.csrfToken)
            }
            
            XCTAssertEqual(response.http.status, .seeOther, message)
            XCTAssertEqual(response.http.headers.firstValue(name: .location), "/login", message)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    private func canGuardAPI(method: HTTPMethod, uri: String) throws {
        
        let message = "\(method): \(uri)"
        
        do {
            let response = try waitResponse(method: method, url: uri) { request in
                try request.setJSONData([String: String](), csrfToken: self.csrfToken)
            }
            
            XCTAssertEqual(response.http.status, .forbidden, message)
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
