//@testable import App
//import Vapor
//import XCTest
//
//final class AdminSiteInfoControllerCSRFTests: ControllerTestCase, AdminTestCase {
//    
//    func testCanPreventCSRFOnUpdate() throws {
//        
//        var response: Response!
//        
//        let form = ["name": "app", "description": "UpdateTest"]
//        
//        response = try waitResponse(method: .POST, url: "/admin/siteinfo/edit") { request in
//            try request.setFormData(form, csrfToken: "")
//        }
//        
//        let sharedSiteInfo = try SiteInfo.query(on: conn).all().wait().first
//        
//        XCTAssertEqual(response.http.status, .forbidden)
//        XCTAssertEqual(sharedSiteInfo?.name, "SiteTitle")
//        XCTAssertEqual(sharedSiteInfo?.description, "Please set up a sentence describing your site.")
//    }
//}
//
//extension AdminSiteInfoControllerCSRFTests {
//    public static let allTests = [
//        ("testCanPreventCSRFOnUpdate", testCanPreventCSRFOnUpdate)
//    ]
//}
