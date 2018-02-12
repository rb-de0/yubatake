@testable import App
import HTTP
import Vapor
import XCTest

final class AdminSiteInfoControllerMessageTests: ControllerTestCase {
    
    func testCanViewValidateErrorOnUpdate() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        var json: JSON!
        var sharedSiteInfo: SiteInfo!
        
        json = [
            "name": "",
            "description": "UpdateTest"
        ]
        
        request = Request(method: .post, uri: "/admin/siteinfo/edit")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/admin/siteinfo/edit")
        
        sharedSiteInfo = try SiteInfo.all().first
        
        XCTAssertEqual(try SiteInfo.all().count, 1)
        XCTAssertEqual(sharedSiteInfo?.name, "SiteTitle")
        XCTAssertEqual(sharedSiteInfo?.description, "Please set up a sentence describing your site.")
        
        request = Request(method: .get, uri: "/admin/tags/create")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertNotNil(view.get("request.storage.error_message") as String?)
    }
}
