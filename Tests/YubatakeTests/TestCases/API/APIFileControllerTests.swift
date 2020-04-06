//@testable import App
//import Vapor
//import XCTest
//
//final class APIFileControllerTests: FileHandleTestCase, AdminTestCase {
//    
//    struct FileGroup: Decodable {
//        let name: String
//        let files: [File]
//    }
//    
//    struct File: Decodable {
//        let name: String
//        let path: String
//    }
//    
//    struct FileBody: Decodable {
//        let path: String
//        let body: String
//    }
//
//    override func setUp() {
//        super.setUp()
//        
//        let defaultDir = fileConfig.themeDir.finished(with: "/").appending("default")
//        let fm = FileManager.default
//        
//        try! fm.createDirectory(atPath: defaultDir, withIntermediateDirectories: true, attributes: nil)
//        fm.createFile(atPath: defaultDir.finished(with: "/").appending("test.leaf"), contents: "Template".data(using: .utf8), attributes: nil)
//        fm.createFile(atPath: defaultDir.finished(with: "/").appending("test.css"), contents: "Style".data(using: .utf8), attributes: nil)
//        fm.createFile(atPath: defaultDir.finished(with: "/").appending("test.js"), contents: "Script".data(using: .utf8), attributes: nil)
//    }
//    
//    func testCanIndexView() throws {
//        
//        let response = try waitResponse(method: .GET, url: "/api/themes/default/files")
//        let groups = try response.content.syncDecode([FileGroup].self)
//        
//        XCTAssertEqual(response.http.status, .ok)
//        XCTAssertEqual(groups.count, 3)
//        
//        XCTAssertEqual(groups[0].files.count, 1)
//        XCTAssertEqual(groups[0].files.first?.name, "test.js")
//        XCTAssertEqual(groups[0].name, "js")
//        
//        XCTAssertEqual(groups[1].files.count, 1)
//        XCTAssertEqual(groups[1].files.first?.name, "test.css")
//        XCTAssertEqual(groups[1].name, "css")
//        
//        XCTAssertEqual(groups[2].files.count, 1)
//        XCTAssertEqual(groups[2].files.first?.name, "test.leaf")
//        XCTAssertEqual(groups[2].name, "leaf")
//    }
//    
//    func testCanShowFileBody() throws {
//        
//        let response = try waitResponse(method: .GET, url: "/api/files?path=/default/test.leaf")
//        let body = try response.content.syncDecode(FileBody.self)
//        
//        XCTAssertEqual(response.http.status, .ok)
//        XCTAssertEqual(body.body, "Template")
//    }
//    
//    func testCanUpdateFileBody() throws {
//        
//        var response: Response!
//        
//        response = try waitResponse(method: .POST, url: "/api/files") { request in
//            try request.setJSONData(["path": "/default/test.leaf", "body": "AfterUpdate"], csrfToken: self.csrfToken)
//        }
//        
//        XCTAssertEqual(response.http.status, .ok)
//        
//        response = try waitResponse(method: .GET, url: "/api/files?path=/default/test.leaf")
//        let body = try response.content.syncDecode(FileBody.self)
//        
//        XCTAssertEqual(response.http.status, .ok)
//        XCTAssertEqual(body.body, "AfterUpdate")
//    }
//}
//
//extension APIFileControllerTests {
//    public static let allTests = [
//        ("testCanIndexView", testCanIndexView),
//        ("testCanShowFileBody", testCanShowFileBody),
//        ("testCanUpdateFileBody", testCanUpdateFileBody)
//    ]
//}
