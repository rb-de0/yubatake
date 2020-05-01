@testable import App
import XCTVapor

final class APIFileControllerTests: ControllerTestCase {
    
    private let fm = FileManager.default
    private static let workDirectory = String.workingDirectory.appending("/.test")
    
    struct FileGroup: Decodable {
        let name: String
        let files: [File]
    }
    
    struct File: Decodable {
        let name: String
        let path: String
    }
    
    struct FileBody: Decodable {
        let path: String
        let body: String
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
        let defaultDir = app.fileConfig.themeDirectory.finished(with: "/").appending("default")
        try! fm.createDirectory(atPath: defaultDir, withIntermediateDirectories: true, attributes: nil)
        fm.createFile(atPath: defaultDir.finished(with: "/").appending("test.leaf"), contents: "Template".data(using: .utf8), attributes: nil)
        fm.createFile(atPath: defaultDir.finished(with: "/").appending("test.css"), contents: "Style".data(using: .utf8), attributes: nil)
        fm.createFile(atPath: defaultDir.finished(with: "/").appending("test.js"), contents: "Script".data(using: .utf8), attributes: nil)
    }
    
    override func tearDown() {
        super.tearDown()
        if fm.fileExists(atPath: Self.workDirectory) {
            try! fm.removeItem(atPath: Self.workDirectory)
        }
    }
    
    func testCanIndexView() throws {
        try test(.GET, "/api/themes/default/files") { response in
            let groups = try response.content.decode([FileGroup].self)
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(groups.count, 3)
    
            XCTAssertEqual(groups[0].files.count, 1)
            XCTAssertEqual(groups[0].files.first?.name, "test.js")
            XCTAssertEqual(groups[0].name, "js")
            
            XCTAssertEqual(groups[1].files.count, 1)
            XCTAssertEqual(groups[1].files.first?.name, "test.css")
            XCTAssertEqual(groups[1].name, "css")
            
            XCTAssertEqual(groups[2].files.count, 1)
            XCTAssertEqual(groups[2].files.first?.name, "test.leaf")
            XCTAssertEqual(groups[2].name, "leaf")
        }
    }
    
    func testCanShowFileBody() throws {
        try test(.GET, "/api/files?path=/default/test.leaf") { response in
            let body = try response.content.decode(FileBody.self)
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(body.body, "Template")
        }
    }
    
    func testCanUpdateFileBody() throws {
        let body = "path=/default/test.leaf&body=AfterUpdate"
        try test(.POST, "/api/files", body: body, withCSRFToken: false) { response in
            XCTAssertEqual(response.status, .forbidden)
        }
        try test(.POST, "/api/files", body: body) { response in
            XCTAssertEqual(response.status, .ok)
        }
        try test(.GET, "/api/files?path=/default/test.leaf") { response in
            let body = try response.content.decode(FileBody.self)
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(body.body, "AfterUpdate")
        }
    }
}

extension APIFileControllerTests {
    public static let allTests = [
        ("testCanIndexView", testCanIndexView),
        ("testCanShowFileBody", testCanShowFileBody),
        ("testCanUpdateFileBody", testCanUpdateFileBody)
    ]
}