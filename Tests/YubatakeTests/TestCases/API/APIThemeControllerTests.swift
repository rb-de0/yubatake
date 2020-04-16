@testable import App
import XCTVapor

final class APIThemeControllerTests: ControllerTestCase {
    
    private let fm = FileManager.default
    private static let workDirectory = String.workingDirectory.appending("/.test")
    
    struct Theme: Decodable {
        let name: String
        let selected: Bool
    }
    
    override func buildApp() -> Application {
        let app = try! ApplicationBuilder.buildForAdmin(workingDirectory: Self.workDirectory)
        return app
    }
    
    override func setUp() {
        super.setUp()
        if !fm.fileExists(atPath: Self.workDirectory) {
            try! fm.createDirectory(atPath: Self.workDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        try! fm.createDirectory(atPath: app.fileConfig.themeDirectory.finished(with: "/").appending("default"), withIntermediateDirectories: true, attributes: nil)
        try! fm.createDirectory(atPath: app.fileConfig.themeDirectory.finished(with: "/").appending("custom"), withIntermediateDirectories: true, attributes: nil)
    }
    
    override func tearDown() {
        super.tearDown()
        if fm.fileExists(atPath: Self.workDirectory) {
            try! fm.removeItem(atPath: Self.workDirectory)
        }
    }
    
    func testCanIndexView() throws {
        try test(.GET, "/api/themes") { response in
            let themes = try response.content.decode([Theme].self)
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(themes.count, 2)
            XCTAssertEqual(themes.first?.name, "custom")
            XCTAssertEqual(themes.first?.selected, false)
            XCTAssertEqual(themes.last?.name, "default")
            XCTAssertEqual(themes.last?.selected, true)
        }
    }
    
    func testCanChangeTheme() throws {
        try test(.POST, "/api/themes", body: "name=custom") { response in
            XCTAssertEqual(response.status, .ok)
        }
        try test(.GET, "/api/themes") { response in
            let themes = try response.content.decode([Theme].self)
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(themes.count, 2)
            XCTAssertEqual(themes.first?.name, "custom")
            XCTAssertEqual(themes.first?.selected, true)
            XCTAssertEqual(themes.last?.name, "default")
            XCTAssertEqual(themes.last?.selected, false)
        }
    }
}

extension APIThemeControllerTests {
    public static let allTests = [
        ("testCanIndexView", testCanIndexView),
        ("testCanChangeTheme", testCanChangeTheme)
    ]
}