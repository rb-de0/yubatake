//@testable import App
//import Vapor
//import XCTest
//
//final class AdminSiteInfoControllerMessageTests: ControllerTestCase, AdminTestCase {
//    
//    func testCanViewValidateErrorOnUpdate() throws {
//        
//        var response: Response!
//        var form: [String: String]
//        var sharedSiteInfo: SiteInfo?
//        
//        form = ["name": "", "description": "UpdateTest"]
//        
//        response = try waitResponse(method: .POST, url: "/admin/siteinfo/edit") { request in
//            try request.setFormData(form, csrfToken: self.csrfToken)
//        }
//        
//        XCTAssertEqual(response.http.status, .seeOther)
//        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/admin/siteinfo/edit")
//        
//        sharedSiteInfo = try SiteInfo.query(on: conn).all().wait().first
//        
//        response = try waitResponse(method: .GET, url: "/admin/siteinfo/edit")
//        
//        XCTAssertEqual(response.http.status, .ok)
//        XCTAssertEqual(view.get("name")?.string, "")
//        XCTAssertEqual(view.get("description")?.string, "UpdateTest")
//        XCTAssertEqual(sharedSiteInfo?.name, "SiteTitle")
//        XCTAssertEqual(sharedSiteInfo?.description, "Please set up a sentence describing your site.")
//        
//        let name = String(repeating: "1", count: 33)
//        let description = String(repeating: "1", count: 129)
//        form = ["name": name, "description": description]
//        
//        response = try waitResponse(method: .POST, url: "/admin/siteinfo/edit") { request in
//            try request.setFormData(form, csrfToken: self.csrfToken)
//        }
//        
//        XCTAssertEqual(response.http.status, .seeOther)
//        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/admin/siteinfo/edit")
//        
//        sharedSiteInfo = try SiteInfo.query(on: conn).all().wait().first
//        
//        response = try waitResponse(method: .GET, url: "/admin/siteinfo/edit")
//        
//        XCTAssertEqual(response.http.status, .ok)
//        XCTAssertEqual(view.get("name")?.string, name)
//        XCTAssertEqual(view.get("description")?.string, description)
//        XCTAssertEqual(sharedSiteInfo?.name, "SiteTitle")
//        XCTAssertEqual(sharedSiteInfo?.description, "Please set up a sentence describing your site.")
//    }
//}
//
//extension AdminSiteInfoControllerMessageTests {
//    public static let allTests = [
//        ("testCanViewValidateErrorOnUpdate", testCanViewValidateErrorOnUpdate)
//    ]
//}
