@testable import App
import Vapor
import XCTest

final class AdminThemeControllerTests: ControllerTestCase, AdminTestCase {
    
    func testCanViewIndex() throws {
        
        let response = try waitResponse(method: .GET, url: "/admin/themes")
        XCTAssertEqual(response.http.status, .ok)
    }
}
