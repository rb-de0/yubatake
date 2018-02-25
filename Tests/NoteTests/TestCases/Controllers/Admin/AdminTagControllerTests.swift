@testable import App
import HTTP
import Vapor
import XCTest

final class AdminTagControllerTests: ControllerTestCase {
    
    func testCanViewIndex() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/admin/tags")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        
        try DataMaker.makeTag("Swift").save()
        
        request = Request(method: .get, uri: "/admin/tags")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        
        XCTAssertEqual(view.get("page.position.max"), 1)
        XCTAssertEqual(view.get("page.position.current"), 1)
        XCTAssertNil(view.get("page.position.next"))
        XCTAssertNil(view.get("page.position.previous"))
        XCTAssertEqual((view.get("data") as Node?)?.array?.count, 1)
    }
    
    func testCanViewPageButtonAtOnePage() throws {
        
        let requestData = try login()
        
        try (1...10).forEach { i in
            try DataMaker.makeTag(String(i)).save()
        }
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/admin/tags")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(view.get("page.position.max"), 1)
        XCTAssertEqual(view.get("page.position.current"), 1)
        XCTAssertNil(view.get("page.position.next"))
        XCTAssertNil(view.get("page.position.previous"))
    }
    
    func testCanViewPageButtonAtTwoPages() throws {
        
        let requestData = try login()
        
        try (1...11).forEach { i in
            try DataMaker.makeTag(String(i)).save()
        }
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/admin/tags")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(view.get("page.position.max"), 2)
        XCTAssertEqual(view.get("page.position.current"), 1)
        XCTAssertEqual(view.get("page.position.next"), 2)
        XCTAssertNil(view.get("page.position.previous"))
        
        request = Request(method: .get, uri: "/admin/tags?page=2")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(view.get("page.position.current"), 2)
        XCTAssertNil(view.get("page.position.next"))
        XCTAssertEqual(view.get("page.position.previous"), 1)
    }
    
    func testCanViewPageButtonAtThreePages() throws {
        
        let requestData = try login()
        
        try (1...21).forEach { i in
            try DataMaker.makeTag(String(i)).save()
        }
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/admin/tags?page=2")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(view.get("page.position.max"), 3)
        XCTAssertEqual(view.get("page.position.current"), 2)
        XCTAssertEqual(view.get("page.position.next"), 3)
        XCTAssertEqual(view.get("page.position.previous"), 1)
    }
    
    func testCanViewCreateView() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/admin/tags/create")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
    }
    
    func testCanViewEditView() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/admin/tags/1/edit")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .notFound)
        
        try DataMaker.makeTag("Swift").save()
        
        request = Request(method: .get, uri: "/admin/tags/1/edit")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
    }
    
    func testCanDestroyATag() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        try DataMaker.makeTag("Swift").save()
        
        request = Request(method: .get, uri: "/admin/tags")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual((view.get("data") as Node?)?.array?.count, 1)
        
        let json: JSON = ["tags": [1]]
        request = Request(method: .post, uri: "/admin/tags/delete")
        try request.setFormData(json, requestData.csrfToken)
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/admin/tags")
        
        request = Request(method: .get, uri: "/admin/tags")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual((view.get("data") as Node?)?.array?.count, 0)
    }
    
    // MARK: - Store/Update
    
    func testCanStoreATag() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        let json = DataMaker.makeTagJSON(name: "Swift")
        
        request = Request(method: .post, uri: "/admin/tags")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/admin/tags/1/edit")
        XCTAssertEqual(try Tag.count(), 1)
    }
    
    func testCannotCreateTagAtAlreadyExist() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        let json = DataMaker.makeTagJSON(name: "Swift")
        
        request = Request(method: .post, uri: "/admin/tags")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/admin/tags/1/edit")
        XCTAssertEqual(try Tag.count(), 1)
        
        request = Request(method: .post, uri: "/admin/tags")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/admin/tags/create")
        XCTAssertEqual(try Tag.count(), 1)
    }
    
    func testCanUpdateATag() throws {
        
        let tag = try DataMaker.makeTag("Swift")
        try tag.save()
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        var json: JSON!
        
        request = Request(method: .get, uri: "/admin/tags/1/edit")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(view.get("name"), "Swift")
        
        json = DataMaker.makeTagJSON(name: "Kotlin")
        
        request = Request(method: .post, uri: "/admin/tags/1/edit")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/admin/tags/1/edit")
        
        request = Request(method: .get, uri: "/admin/tags/1/edit")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(view.get("name"), "Kotlin")
    }
}

extension AdminTagControllerTests {
    public static let allTests = [
        ("testCanViewIndex", testCanViewIndex),
        ("testCanViewPageButtonAtOnePage", testCanViewPageButtonAtOnePage),
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