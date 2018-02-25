@testable import App
import Cookies
import HTTP
import Vapor
import XCTest

final class APIHtmlControllerTests: ControllerTestCase {
    
    func testCanViewIndex() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .post, uri: "/api/converted_markdown")
        request.cookies.insert(requestData.cookie)
        try request.setJSONData(["content": "#hoge"], requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
    }
    
    func testCannotContinueConvertingOnNoContent() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .post, uri: "/api/converted_markdown")
        request.cookies.insert(requestData.cookie)
        try request.setJSONData([:], requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .badRequest)
    }
}

extension APIHtmlControllerTests {
    public static let allTests = [
        ("testCanViewIndex", testCanViewIndex),
        ("testCannotContinueConvertingOnNoContent", testCannotContinueConvertingOnNoContent)
    ]
}