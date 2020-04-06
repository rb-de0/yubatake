//@testable import App
//import Vapor
//import XCTest
//
//final class APIFileControllerCSRFTests: FileHandleTestCase, AdminTestCase {
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
//    func testCanPreventCSRFUpdateFileBody() throws {
//        
//        var response: Response!
//        
//        response = try waitResponse(method: .POST, url: "/api/files") { request in
//            try request.setJSONData(["path": "/default/test.leaf", "body": "AfterUpdate"], csrfToken: "")
//        }
//        
//        XCTAssertEqual(response.http.status, .forbidden)
//        
//        response = try waitResponse(method: .GET, url: "/api/files?path=/default/test.leaf")
//        let body = try response.content.syncDecode(FileBody.self)
//        
//        XCTAssertEqual(response.http.status, .ok)
//        XCTAssertEqual(body.body, "Template")
//    }
//}
//
//extension APIFileControllerCSRFTests {
//    public static let allTests = [
//        ("testCanPreventCSRFUpdateFileBody", testCanPreventCSRFUpdateFileBody)
//    ]
//}
