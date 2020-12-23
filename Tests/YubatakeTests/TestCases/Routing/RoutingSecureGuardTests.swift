@testable import App
import XCTVapor

final class RoutingSecureGuardTests: ControllerTestCase {
    
    override func buildApp() -> Application {
        return try! ApplicationBuilder.build()
    }
    
    func testCanGuardRequest() throws {
        
        // Posts
        try canGuard(method: .GET, path: "/admin/posts")
        try canGuard(method: .GET, path: "/admin/posts/create")
        try canGuard(method: .GET, path: "/admin/posts/1/edit")
        try canGuard(method: .POST, path: "/admin/posts")
        try canGuard(method: .POST, path: "/admin/posts/1/edit")
        try canGuard(method: .POST, path: "/admin/posts/delete")
        try canGuard(method: .GET, path: "/admin/posts/1/preview")
        
        // Tags
        try canGuard(method: .GET, path: "/admin/tags")
        try canGuard(method: .GET, path: "/admin/tags/create")
        try canGuard(method: .GET, path: "/admin/tags/1/edit")
        try canGuard(method: .POST, path: "/admin/tags")
        try canGuard(method: .POST, path: "/admin/tags/1/edit")
        try canGuard(method: .POST, path: "/admin/tags/delete")
        
        // Categories
        try canGuard(method: .GET, path: "/admin/categories")
        try canGuard(method: .GET, path: "/admin/categories/create")
        try canGuard(method: .GET, path: "/admin/categories/1/edit")
        try canGuard(method: .POST, path: "/admin/categories")
        try canGuard(method: .POST, path: "/admin/categories/1/edit")
        try canGuard(method: .POST, path: "/admin/categories/delete")
        
        // Images
        try canGuard(method: .GET, path: "/admin/images")
        try canGuard(method: .GET, path: "/admin/images/1/edit")
        try canGuard(method: .POST, path: "/admin/images/1/edit")
        try canGuard(method: .POST, path: "/admin/images/1/delete")
        try canGuard(method: .POST, path: "/admin/images/cleanup")
        
        // Themes
        try canGuard(method: .GET, path: "/admin/themes")
        
        // Files
        try canGuard(method: .GET, path: "/admin/static-contents")
        
        // SiteInfo
        try canGuard(method: .GET, path: "/admin/siteinfo/edit")
        try canGuard(method: .POST, path: "/admin/siteinfo/edit")
        
        // User
        try canGuard(method: .GET, path: "/admin/user/edit")
        try canGuard(method: .POST, path: "/admin/user/edit")
    }

    func testCanGuardAPIRequest() throws {
        
        // Images
        try canGuardAPI(method: .GET, path: "/api/images")
        try canGuardAPI(method: .POST, path: "/api/images")
        
        // Files
        try canGuardAPI(method: .GET, path: "/api/themes/default/files")
        try canGuardAPI(method: .GET, path: "/api/files")
        try canGuardAPI(method: .POST, path: "/api/files")
        
        // Themes
        try canGuardAPI(method: .GET, path: "/api/themes")
        try canGuardAPI(method: .POST, path: "/api/themes")
    }
    
    private func canGuard(method: HTTPMethod, path: String) throws {
        try test(method, path, afterResponse:  { response in
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers.first(name: .location), "/login")
        })
    }
    
    private func canGuardAPI(method: HTTPMethod, path: String) throws {
        try test(method, path, afterResponse:  { response in
            XCTAssertEqual(response.status, .forbidden)
        })
    }
}

extension RoutingSecureGuardTests {
    public static let allTests = [
        ("testCanGuardRequest", testCanGuardRequest),
        ("testCanGuardAPIRequest", testCanGuardAPIRequest)
    ]
}
