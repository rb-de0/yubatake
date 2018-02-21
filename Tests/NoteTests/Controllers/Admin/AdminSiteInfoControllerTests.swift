@testable import App
import HTTP
import Vapor
import XCTest

final class AdminSiteInfoControllerTests: ControllerTestCase {

    func testCreateSharedSiteInfo() throws {
        
        let count = try SiteInfo.all().count
        let sharedSiteInfo = try SiteInfo.all().first
        
        XCTAssertEqual(count, 1)
        XCTAssertEqual(sharedSiteInfo?.name, "SiteTitle")
        XCTAssertEqual(sharedSiteInfo?.description, "Please set up a sentence describing your site.")
    }
    
    func testCanViewCreateView() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/admin/siteinfo/edit")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
    }
    
    func testCanUpdateASiteInfo() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        let json: JSON = [
            "name": "note",
            "description": "UpdateTest"
        ]
        
        request = Request(method: .post, uri: "/admin/siteinfo/edit")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/admin/siteinfo/edit")
        
        let count = try SiteInfo.all().count
        let sharedSiteInfo = try SiteInfo.all().first
        
        XCTAssertEqual(count, 1)
        XCTAssertEqual(sharedSiteInfo?.name, "note")
        XCTAssertEqual(sharedSiteInfo?.description, "UpdateTest")
    }
}

extension AdminSiteInfoControllerTests {
    
	public static var allTests = [
		("testCreateSharedSiteInfo", testCreateSharedSiteInfo),
		("testCanViewCreateView", testCanViewCreateView),
		("testCanUpdateASiteInfo", testCanUpdateASiteInfo)
    ]
}
