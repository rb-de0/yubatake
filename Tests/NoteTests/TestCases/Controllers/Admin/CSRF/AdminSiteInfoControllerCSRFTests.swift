@testable import App
import HTTP
import Vapor
import XCTest

final class AdminSiteInfoControllerCSRFTests: ControllerTestCase {

    func testCanPreventCSRFOnUpdate() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        let json: JSON = [
            "name": "note",
            "description": "UpdateTest"
        ]
        
        request = Request(method: .post, uri: "/admin/siteinfo/edit")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, "")
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .forbidden)
        XCTAssertEqual(try SiteInfo.find(1)?.name, "SiteTitle")
    }
}

extension AdminSiteInfoControllerCSRFTests {
    public static let allTests = [
        ("testCanPreventCSRFOnUpdate", testCanPreventCSRFOnUpdate)
    ]
}