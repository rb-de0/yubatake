@testable import App
import Vapor
import XCTest

final class APIThemeControllerTests: FileHandleTestCase, AdminTestCase {
    
    struct Theme: Decodable {
        let name: String
        let selected: Bool
    }
    
    override func setUp() {
        super.setUp()
        try! FileManager.default.createDirectory(atPath: fileConfig.themeDir.finished(with: "/").appending("default"), withIntermediateDirectories: true, attributes: nil)
        try! FileManager.default.createDirectory(atPath: fileConfig.themeDir.finished(with: "/").appending("custom"), withIntermediateDirectories: true, attributes: nil)
    }
    
    func testCanIndexView() throws {
        
        let siteInfo = try SiteInfo.shared(on: conn).wait()
        XCTAssertNil(siteInfo.theme)
        
        let response = try waitResponse(method: .GET, url: "/api/themes")
        let themes = try response.content.syncDecode([Theme].self)
        
        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(themes.count, 2)
        XCTAssertEqual(themes.first?.name, "custom")
        XCTAssertEqual(themes.first?.selected, false)
        XCTAssertEqual(themes.last?.name, "default")
        XCTAssertEqual(themes.last?.selected, true)
    }
    
    func testCanChangeTheme() throws  {
        
        var response: Response!
        
        response = try waitResponse(method: .POST, url: "/api/themes") { request in
            try request.setJSONData(["name": "custom"], csrfToken: self.csrfToken)
        }
        
        XCTAssertEqual(response.http.status, .ok)
        
        let siteInfo = try SiteInfo.shared(on: conn).wait()
        XCTAssertEqual(siteInfo.theme, "custom")
        
        response = try waitResponse(method: .GET, url: "/api/themes")
        let themes = try response.content.syncDecode([Theme].self)
        
        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(themes.count, 2)
        XCTAssertEqual(themes.first?.name, "custom")
        XCTAssertEqual(themes.first?.selected, true)
        XCTAssertEqual(themes.last?.name, "default")
        XCTAssertEqual(themes.last?.selected, false)
    }
}

extension APIThemeControllerTests {
    public static let allTests = [
        ("testCanIndexView", testCanIndexView),
        ("testCanChangeTheme", testCanChangeTheme)
    ]
}