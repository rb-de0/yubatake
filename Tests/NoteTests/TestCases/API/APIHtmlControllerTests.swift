@testable import App
import Vapor
import XCTest

final class APIHtmlControllerTests: ControllerTestCase, AdminTestCase {
    
    func testCanViewIndex() throws {
        
        let response = try waitResponse(method: .POST, url: "/api/converted_markdown") { request in
            try request.setJSONData(["content": "#hoge"], csrfToken: self.csrfToken)
        }
        
        XCTAssertEqual(response.http.status, .ok)
    }
    
    func testCannotContinueConvertingOnNoContent() throws {
        
        let response = try waitResponse(method: .POST, url: "/api/converted_markdown") { request in
            try request.setJSONData([String: String](), csrfToken: self.csrfToken)
        }
        
        XCTAssertEqual(response.http.status, .badRequest)
    }
}

extension APIHtmlControllerTests {
    public static let allTests = [
        ("testCanViewIndex", testCanViewIndex),
        ("testCannotContinueConvertingOnNoContent", testCannotContinueConvertingOnNoContent)
    ]
}