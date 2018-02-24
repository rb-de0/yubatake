@testable import App
import HTTP
import Vapor
import XCTest

final class AdminFileControllerTests: ControllerTestCase {
    
    func testCanViewIndex() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/admin/files")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
    }
}

extension AdminFileControllerTests {
    public static let allTests = [
        ("testCanViewIndex", testCanViewIndex)
    ]
}