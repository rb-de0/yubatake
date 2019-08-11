@testable import App
import Vapor
import XCTest

final class AdminTagControllerTests: ControllerTestCase, AdminTestCase {
    
    func testCanViewIndex() throws {
        
        var response: Response!
        
        response = try waitResponse(method: .GET, url: "/admin/tags")
        
        XCTAssertEqual(response.http.status, .ok)
        
        _ = try DataMaker.makeTag("Swift").save(on: conn).wait()

        response = try waitResponse(method: .GET, url: "/admin/tags")
        
        XCTAssertEqual(response.http.status, .ok)
        
        XCTAssertEqual(view.get("page.position.max")?.int, 1)
        XCTAssertEqual(view.get("page.position.current")?.int, 1)
        XCTAssertNil(view.get("page.position.next"))
        XCTAssertNil(view.get("page.position.previous"))
        XCTAssertEqual(view.get("data")?.array?.count, 1)
        XCTAssertEqual(try Tag.query(on: conn).count().wait(), 1)
    }
    
    func testCanViewPageButtonAtTwoPages() throws {
        
        var response: Response!
        
        try (1...11).forEach { i in
            _ = try DataMaker.makeTag(String(i)).save(on: conn).wait()
        }
        
        XCTAssertEqual(try Tag.query(on: conn).count().wait(), 11)
        
        response = try waitResponse(method: .GET, url: "/admin/tags")
        
        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(view.get("page.position.max")?.int, 2)
        XCTAssertEqual(view.get("page.position.current")?.int, 1)
        XCTAssertEqual(view.get("page.position.next")?.int, 2)
        XCTAssertNil(view.get("page.position.previous"))
        XCTAssertEqual(view.get("data")?.array?.count, 10)
        
        response = try waitResponse(method: .GET, url: "/admin/tags?page=2")
        
        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(view.get("page.position.current")?.int, 2)
        XCTAssertNil(view.get("page.position.next"))
        XCTAssertEqual(view.get("page.position.previous")?.int, 1)
        XCTAssertEqual(view.get("data")?.array?.count, 1)
    }
    
    func testCanViewPageButtonAtThreePages() throws {
        
        var response: Response!
        
        try (1...21).forEach { i in
            _ = try DataMaker.makeTag(String(i)).save(on: conn).wait()
        }
        
        XCTAssertEqual(try Tag.query(on: conn).count().wait(), 21)
        
        response = try waitResponse(method: .GET, url: "/admin/tags?page=2")
        
        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(view.get("page.position.max")?.int, 3)
        XCTAssertEqual(view.get("page.position.current")?.int, 2)
        XCTAssertEqual(view.get("page.position.next")?.int, 3)
        XCTAssertEqual(view.get("page.position.previous")?.int, 1)
        XCTAssertEqual(view.get("data")?.array?.count, 10)
    }
    
    func testCanViewCreateView() throws {
        let response = try waitResponse(method: .GET, url: "/admin/tags/create")
        XCTAssertEqual(response.http.status, .ok)
    }
    
    func testCanViewEditView() throws {
        
        var response: Response!

        response = try waitResponse(method: .GET, url: "/admin/tags/1/edit")
        
        XCTAssertEqual(response.http.status, .notFound)
        
        _ = try DataMaker.makeTag("Swift").save(on: conn).wait()
        
        response = try waitResponse(method: .GET, url: "/admin/tags/1/edit")
        
        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(view.get("name")?.string, "Swift")
    }
    
    func testCanDestroyATag() throws {

        var response: Response!
        
        _ = try DataMaker.makeTag("Swift").save(on: conn).wait()
        
        response = try waitResponse(method: .POST, url: "/admin/tags/delete") { request in
            try request.setFormData(["tags": [1]], csrfToken: self.csrfToken)
        }
        
        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/admin/tags")
        
        XCTAssertEqual(try Tag.query(on: conn).count().wait(), 0)
    }
    
    // MARK: - Store/Update
    
    func testCanStoreATag() throws {
        
        var response: Response!
        
        let form = DataMaker.makeTagFormForTest("Swift")
        
        response = try waitResponse(method: .POST, url: "/admin/tags") { request in
            try request.setFormData(form, csrfToken: self.csrfToken)
        }
        
        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/admin/tags/1/edit")
        XCTAssertEqual(try Tag.query(on: conn).count().wait(), 1)
        
        response = try waitResponse(method: .GET, url: "/admin/tags/1/edit")
        
        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(view.get("name")?.string, "Swift")
        XCTAssertEqual(try Tag.query(on: conn).first().wait()?.name, "Swift")
    }
    
    func testCannotCreateTagAtAlreadyExist() throws {
        
        var response: Response!
        
        let form = DataMaker.makeTagFormForTest("Swift")
        
        response = try waitResponse(method: .POST, url: "/admin/tags") { request in
            try request.setFormData(form, csrfToken: self.csrfToken)
        }
        
        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/admin/tags/1/edit")
        XCTAssertEqual(try Tag.query(on: conn).count().wait(), 1)
        
        response = try waitResponse(method: .POST, url: "/admin/tags") { request in
            try request.setFormData(form, csrfToken: self.csrfToken)
        }
        
        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/admin/tags/create")
        XCTAssertEqual(try Tag.query(on: conn).count().wait(), 1)
    }
    
    func testCanUpdateATag() throws {
 
        var response: Response!
        
        _ = try DataMaker.makeTag("Swift").save(on: conn).wait()
        
        let form = DataMaker.makeCategoryFormForTest("Kotlin")
        
        response = try waitResponse(method: .POST, url: "/admin/tags/1/edit") { request in
            try request.setFormData(form, csrfToken: self.csrfToken)
        }
        
        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/admin/tags/1/edit")
        
        response = try waitResponse(method: .GET, url: "/admin/tags/1/edit")
        
        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(view.get("name")?.string, "Kotlin")
        XCTAssertEqual(try Tag.query(on: conn).first().wait()?.name, "Kotlin")
    }
}

extension AdminTagControllerTests {
    public static let allTests = [
        ("testCanViewIndex", testCanViewIndex),
        ("testCanViewPageButtonAtTwoPages", testCanViewPageButtonAtTwoPages),
        ("testCanViewPageButtonAtThreePages", testCanViewPageButtonAtThreePages),
        ("testCanViewCreateView", testCanViewCreateView),
        ("testCanViewEditView", testCanViewEditView),
        ("testCanDestroyATag", testCanDestroyATag),
        ("testCanStoreATag", testCanStoreATag),
        ("testCannotCreateTagAtAlreadyExist", testCannotCreateTagAtAlreadyExist),
        ("testCanUpdateATag", testCanUpdateATag)
    ]
}