@testable import App
import Vapor
import XCTest

final class AdminTagControllerCSRFTests: ControllerTestCase, AdminTestCase {
    
    func testCanPreventCSRFOnDestroy() throws {
        
        var response: Response!
        
        _ = try DataMaker.makeTag("Swift").save(on: conn).wait()
        
        XCTAssertEqual(try Tag.query(on: conn).count().wait(), 1)
        
        response = try waitResponse(method: .POST, url: "/admin/tags/delete") { request in
            try request.setFormData(["tags": [1]], csrfToken: "")
        }
        
        XCTAssertEqual(response.http.status, .forbidden)
        
        response = try waitResponse(method: .GET, url: "/admin/tags")
        
        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(try Tag.query(on: conn).count().wait(), 1)
        XCTAssertEqual(view.get("data")?.array?.count, 1)
    }
    
    func testCanPreventCSRFOnStore() throws {
        
        var response: Response!
        
        let form = DataMaker.makeTagFormForTest("Swift")
        
        response = try waitResponse(method: .POST, url: "/admin/tags") { request in
            try request.setFormData(form, csrfToken: "")
        }
        
        XCTAssertEqual(response.http.status, .forbidden)
        
        response = try waitResponse(method: .GET, url: "/admin/tags")
        
        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(try Tag.query(on: conn).count().wait(), 0)
        XCTAssertEqual(view.get("data")?.array?.count, 0)
    }
    
    func testCanPreventCSRFOnUpdate() throws {
        
        var response: Response!
        
        _ = try DataMaker.makeTag("Swift").save(on: conn).wait()
        
        XCTAssertEqual(try Tag.query(on: conn).first().wait()?.name, "Swift")
        
        let form = DataMaker.makeCategoryFormForTest("Kotlin")
        
        response = try waitResponse(method: .POST, url: "/admin/tags/1/edit") { request in
            try request.setFormData(form, csrfToken: "")
        }
        
        XCTAssertEqual(response.http.status, .forbidden)
        XCTAssertEqual(try Tag.query(on: conn).first().wait()?.name, "Swift")
    }
}

extension AdminTagControllerCSRFTests {
    public static let allTests = [
        ("testCanPreventCSRFOnDestroy", testCanPreventCSRFOnDestroy),
        ("testCanPreventCSRFOnStore", testCanPreventCSRFOnStore),
        ("testCanPreventCSRFOnUpdate", testCanPreventCSRFOnUpdate)
    ]
}