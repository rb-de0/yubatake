@testable import App
import Vapor
import XCTest

final class AdminSiteInfoControllerTests: ControllerTestCase, AdminTestCase {
    
    func testCreateSharedSiteInfo() throws {

        let count = try SiteInfo.query(on: conn).count().wait()
        let sharedSiteInfo = try SiteInfo.query(on: conn).all().wait().first
        
        XCTAssertEqual(count, 1)
        XCTAssertEqual(sharedSiteInfo?.name, "SiteTitle")
        XCTAssertEqual(sharedSiteInfo?.description, "Please set up a sentence describing your site.")
    }
    
    func testCanViewCreateView() throws {
        
        var response: Response!
        
        response = try waitResponse(method: .GET, url: "/admin/siteinfo/edit")
        
        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(view.get("name")?.string, "SiteTitle")
        XCTAssertEqual(view.get("description")?.string, "Please set up a sentence describing your site.")
    }
    
    func testCanUpdateASiteInfo() throws {

        var response: Response!
        
        let form = ["name": "app", "description": "UpdateTest"]
        
        response = try waitResponse(method: .POST, url: "/admin/siteinfo/edit") { request in
            try request.setFormData(form, csrfToken: self.csrfToken)
        }
        
        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/admin/siteinfo/edit")
        
        let sharedSiteInfo = try SiteInfo.query(on: conn).all().wait().first
        
        response = try waitResponse(method: .GET, url: "/admin/siteinfo/edit")
        
        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(view.get("name")?.string, "app")
        XCTAssertEqual(view.get("description")?.string, "UpdateTest")
        XCTAssertEqual(sharedSiteInfo?.name, "app")
        XCTAssertEqual(sharedSiteInfo?.description, "UpdateTest")
    }
}

extension AdminSiteInfoControllerTests {
    public static let allTests = [
        ("testCreateSharedSiteInfo", testCreateSharedSiteInfo),
        ("testCanViewCreateView", testCanViewCreateView),
        ("testCanUpdateASiteInfo", testCanUpdateASiteInfo)
    ]
}