@testable import App
import XCTVapor

final class AdminSiteInfoControllerTests: ControllerTestCase {
    
    func testCanCreateSharedSiteInfo() throws {
        let count = try SiteInfo.query(on: db).count().wait()
        let siteInfo = try SiteInfo.query(on: db).all().wait().first
        XCTAssertEqual(count, 1)
        XCTAssertEqual(siteInfo?.name, "SiteTitle")
        XCTAssertEqual(siteInfo?.description, "Please set up a sentence describing your site.")
    }
    
    func testCanViewCreateView() throws {
        try test(.GET, "/admin/siteinfo/edit") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("name")?.string, "SiteTitle")
            XCTAssertEqual(view.get("description")?.string, "Please set up a sentence describing your site.")
        }
    }
    
    func testCanUpdateASiteInfo() throws {
        try test(.POST, "/admin/siteinfo/edit", body: "name=app&description=UpdateTest") { response in
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers.first(name: .location), "/admin/siteinfo/edit")
        }
        try test(.GET, "/admin/siteinfo/edit") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("name")?.string, "app")
            XCTAssertEqual(view.get("description")?.string, "UpdateTest")
        }
    }
    
    func testCannotUpdateInvalidFormData() throws {
        do {
            try test(.POST, "/admin/siteinfo/edit", body: "name=&description=UpdateTest") { response in
                XCTAssertEqual(response.status, .seeOther)
                XCTAssertEqual(response.headers.first(name: .location), "/admin/siteinfo/edit")
            }
            try test(.GET, "/admin/siteinfo/edit") { response in
                XCTAssertNotNil(view.get("errorMessage"))
            }
            let siteInfo = try SiteInfo.find(1, on: db).wait()
            XCTAssertEqual(siteInfo?.name, "SiteTitle")
            XCTAssertEqual(siteInfo?.description, "Please set up a sentence describing your site.")
        }
        do {
            try test(.POST, "/admin/siteinfo/edit", body: "name=app&description=") { response in
                XCTAssertEqual(response.status, .seeOther)
                XCTAssertEqual(response.headers.first(name: .location), "/admin/siteinfo/edit")
            }
            try test(.GET, "/admin/siteinfo/edit") { response in
                XCTAssertNotNil(view.get("errorMessage"))
            }
            let siteInfo = try SiteInfo.find(1, on: db).wait()
            XCTAssertEqual(siteInfo?.name, "SiteTitle")
            XCTAssertEqual(siteInfo?.description, "Please set up a sentence describing your site.")
        }
        do {
            let longName = String(repeating: "a", count: 33)
            try test(.POST, "/admin/siteinfo/edit", body: "name=\(longName)&description=UpdateTest") { response in
                XCTAssertEqual(response.status, .seeOther)
                XCTAssertEqual(response.headers.first(name: .location), "/admin/siteinfo/edit")
            }
            try test(.GET, "/admin/siteinfo/edit") { response in
                XCTAssertNotNil(view.get("errorMessage"))
            }
            let siteInfo = try SiteInfo.find(1, on: db).wait()
            XCTAssertEqual(siteInfo?.name, "SiteTitle")
            XCTAssertEqual(siteInfo?.description, "Please set up a sentence describing your site.")
        }
        do {
            let longDescription = String(repeating: "a", count: 129)
            try test(.POST, "/admin/siteinfo/edit", body: "name=app&description=\(longDescription)") { response in
                XCTAssertEqual(response.status, .seeOther)
                XCTAssertEqual(response.headers.first(name: .location), "/admin/siteinfo/edit")
            }
            try test(.GET, "/admin/siteinfo/edit") { response in
                XCTAssertNotNil(view.get("errorMessage"))
            }
            let siteInfo = try SiteInfo.find(1, on: db).wait()
            XCTAssertEqual(siteInfo?.name, "SiteTitle")
            XCTAssertEqual(siteInfo?.description, "Please set up a sentence describing your site.")
        }
    }
}

extension AdminSiteInfoControllerTests {
    public static let allTests = [
        ("testCanCreateSharedSiteInfo", testCanCreateSharedSiteInfo),
        ("testCanViewCreateView", testCanViewCreateView),
        ("testCanUpdateASiteInfo", testCanUpdateASiteInfo),
        ("testCannotUpdateInvalidFormData", testCannotUpdateInvalidFormData)
    ]
}