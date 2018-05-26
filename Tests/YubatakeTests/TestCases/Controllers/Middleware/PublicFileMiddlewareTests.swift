@testable import App
import Vapor
import XCTest

final class PublicFileMiddlewareTests: ControllerTestCase {
    
    func testCanRespondFiles() throws {
        
        var response: Response!
        
        response = try waitResponse(method: .GET, url: "/themes/default/styles/style.css")
        XCTAssertEqual(response.http.status, .ok)
        
        response = try waitResponse(method: .GET, url: "/themes/pure/js/menu.js")
        XCTAssertEqual(response.http.status, .ok)
        
        response = try waitResponse(method: .GET, url: "/js/file-editor.js")
        XCTAssertEqual(response.http.status, .ok)
    }
    
    func testCanProtectTemplateFiles() throws {
        
        let response = try waitResponse(method: .GET, url: "/themes/default/template/post.leaf")
        XCTAssertEqual(response.http.status, .notFound)
    }
}

extension PublicFileMiddlewareTests {
    public static let allTests = [
        ("testCanRespondFiles", testCanRespondFiles),
        ("testCanProtectTemplateFiles", testCanProtectTemplateFiles)
    ]
}