@testable import App
import HTTP
import Vapor
import XCTest

final class AdminCategoryControllerTests: ControllerTestCase {
    
    func testCanViewIndex() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/admin/categories")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        
        try DataMaker.makeCategory("Programming").save()
        
        request = Request(method: .get, uri: "/admin/categories")
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
            try DataMaker.makeCategory(String(i)).save()
        }
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/admin/categories")
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
            try DataMaker.makeCategory(String(i)).save()
        }
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/admin/categories")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(view.get("page.position.max"), 2)
        XCTAssertEqual(view.get("page.position.current"), 1)
        XCTAssertEqual(view.get("page.position.next"), 2)
        XCTAssertNil(view.get("page.position.previous"))
        
        request = Request(method: .get, uri: "/admin/categories?page=2")
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
            try DataMaker.makeCategory(String(i)).save()
        }
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/admin/categories?page=2")
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
        
        request = Request(method: .get, uri: "/admin/categories/create")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
    }
    
    func testCanViewEditView() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/admin/categories/1/edit")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .notFound)
        
        try DataMaker.makeCategory("Programming").save()
        
        request = Request(method: .get, uri: "/admin/categories/1/edit")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
    }
    
    func testCanDestroyCategories() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        try DataMaker.makeCategory("Programming").save()
        
        request = Request(method: .get, uri: "/admin/categories")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual((view.get("data") as Node?)?.array?.count, 1)
        
        let json: JSON = ["categories": [1]]
        request = Request(method: .post, uri: "/admin/categories/delete")
        try request.setFormData(json, requestData.csrfToken)
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/admin/categories")
        
        request = Request(method: .get, uri: "/admin/categories")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual((view.get("data") as Node?)?.array?.count, 0)
    }
    
    // MARK: - Store/Update
    
    func testCanStoreACategory() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        let json = DataMaker.makeCategoryJSON(name: "Programming")
        
        request = Request(method: .post, uri: "/admin/categories")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/admin/categories/1/edit")
        XCTAssertEqual(try App.Category.count(), 1)
    }
    
    func testCannotCreateCategoryAtAlreadyExist() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        let json = DataMaker.makeCategoryJSON(name: "Programming")
        
        request = Request(method: .post, uri: "/admin/categories")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/admin/categories/1/edit")
        XCTAssertEqual(try App.Category.count(), 1)
        
        request = Request(method: .post, uri: "/admin/categories")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/admin/categories/create")
        XCTAssertEqual(try App.Category.count(), 1)
    }
    
    func testCanUpdateACategory() throws {
        
        let category = try DataMaker.makeCategory("Programming")
        try category.save()
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        var json: JSON!
        
        request = Request(method: .get, uri: "/admin/categories/1/edit")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(view.get("name"), "Programming")
        
        json = DataMaker.makeCategoryJSON(name: "FX")
        
        request = Request(method: .post, uri: "/admin/categories/1/edit")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/admin/categories/1/edit")
        
        request = Request(method: .get, uri: "/admin/categories/1/edit")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(view.get("name"), "FX")
    }
}

extension AdminCategoryControllerTests {
    
	public static var allTests = [
		("testCanViewCreateView", testCanViewCreateView),
		("testCanViewPageButtonAtTwoPages", testCanViewPageButtonAtTwoPages),
		("testCanViewEditView", testCanViewEditView),
		("testCanViewPageButtonAtOnePage", testCanViewPageButtonAtOnePage),
		("testCanDestroyCategories", testCanDestroyCategories),
		("testCanViewPageButtonAtThreePages", testCanViewPageButtonAtThreePages),
		("testCanStoreACategory", testCanStoreACategory),
		("testCanViewIndex", testCanViewIndex),
		("testCannotCreateCategoryAtAlreadyExist", testCannotCreateCategoryAtAlreadyExist),
		("testCanUpdateACategory", testCanUpdateACategory)
    ]
}
