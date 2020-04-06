//@testable import App
//import Vapor
//import XCTest
//
//final class AdminCategoryControllerTests: ControllerTestCase, AdminTestCase {
//
//    func testCanViewIndex() throws {
//
//        var response: Response!
//        
//        response = try waitResponse(method: .GET, url: "/admin/categories")
//        
//        XCTAssertEqual(response.http.status, .ok)
//        
//        _ = try DataMaker.makeCategory("Programming").save(on: conn).wait()
//        
//        response = try waitResponse(method: .GET, url: "/admin/categories")
//        
//        XCTAssertEqual(response.http.status, .ok)
//        XCTAssertEqual(view.get("page.position.max")?.int, 1)
//        XCTAssertEqual(view.get("page.position.current")?.int, 1)
//        XCTAssertNil(view.get("page.position.next"))
//        XCTAssertNil(view.get("page.position.previous"))
//        XCTAssertEqual(view.get("data")?.array?.count, 1)
//        XCTAssertEqual(try App.Category.query(on: conn).count().wait(), 1)
//    }
//    
//    func testCanViewPageButtonAtTwoPages() throws {
//        
//        var response: Response!
//
//        try (1...11).forEach { i in
//            _ = try DataMaker.makeCategory(String(i)).save(on: conn).wait()
//        }
//        
//        XCTAssertEqual(try App.Category.query(on: conn).count().wait(), 11)
//        
//        response = try waitResponse(method: .GET, url: "/admin/categories")
//        
//        XCTAssertEqual(response.http.status, .ok)
//        XCTAssertEqual(view.get("page.position.max")?.int, 2)
//        XCTAssertEqual(view.get("page.position.current")?.int, 1)
//        XCTAssertEqual(view.get("page.position.next")?.int, 2)
//        XCTAssertNil(view.get("page.position.previous"))
//        XCTAssertEqual(view.get("data")?.array?.count, 10)
//        
//        response = try waitResponse(method: .GET, url: "/admin/categories?page=2")
//        
//        XCTAssertEqual(response.http.status, .ok)
//        XCTAssertEqual(view.get("page.position.max")?.int, 2)
//        XCTAssertEqual(view.get("page.position.current")?.int, 2)
//        XCTAssertNil(view.get("page.position.next"))
//        XCTAssertEqual(view.get("page.position.previous")?.int, 1)
//        XCTAssertEqual(view.get("data")?.array?.count, 1)
//    }
//    
//    func testCanViewPageButtonAtThreePages() throws {
//        
//        var response: Response!
//        
//        try (1...21).forEach { i in
//            _ = try DataMaker.makeCategory(String(i)).save(on: conn).wait()
//        }
//        
//        XCTAssertEqual(try App.Category.query(on: conn).count().wait(), 21)
//        
//        response = try waitResponse(method: .GET, url: "/admin/categories?page=2")
//        
//        XCTAssertEqual(response.http.status, .ok)
//        XCTAssertEqual(view.get("page.position.max")?.int, 3)
//        XCTAssertEqual(view.get("page.position.current")?.int, 2)
//        XCTAssertEqual(view.get("page.position.next")?.int, 3)
//        XCTAssertEqual(view.get("page.position.previous")?.int, 1)
//        XCTAssertEqual(view.get("data")?.array?.count, 10)
//    }
//    
//    func testCanViewCreateView() throws {
//        let response = try waitResponse(method: .GET, url: "/admin/categories/create")
//        XCTAssertEqual(response.http.status, .ok)
//    }
//    
//    func testCanViewEditView() throws {
//        
//        var response: Response!
//        
//        response = try waitResponse(method: .GET, url: "/admin/categories/1/edit")
//        
//        XCTAssertEqual(response.http.status, .notFound)
//        
//        _ = try DataMaker.makeCategory("Programming").save(on: conn).wait()
//        
//        response = try waitResponse(method: .GET, url: "/admin/categories/1/edit")
//        
//        XCTAssertEqual(response.http.status, .ok)
//        XCTAssertEqual(view.get("name")?.string, "Programming")
//    }
//    
//    func testCanDestroyACategory() throws {
//
//        var response: Response!
//        
//         _ = try DataMaker.makeCategory("Programming").save(on: conn).wait()
//        
//        XCTAssertEqual(try App.Category.query(on: conn).count().wait(), 1)
//        
//        response = try waitResponse(method: .POST, url: "/admin/categories/delete") { request in
//             try request.setFormData(["categories": [1]], csrfToken: self.csrfToken)
//        }
//
//        XCTAssertEqual(response.http.status, .seeOther)
//        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/admin/categories")
//        XCTAssertEqual(try App.Category.query(on: conn).count().wait(), 0)
//    }
//    
//    // MARK: - Store/Update
//    
//    func testCanStoreACategory() throws {
//        
//        var response: Response!
//        
//        let form = DataMaker.makeCategoryFormForTest("Programming")
//
//        response = try waitResponse(method: .POST, url: "/admin/categories") { request in
//            try request.setFormData(form, csrfToken: self.csrfToken)
//        }
//        
//        XCTAssertEqual(response.http.status, .seeOther)
//        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/admin/categories/1/edit")
//        XCTAssertEqual(try App.Category.query(on: conn).count().wait(), 1)
//        
//        response = try waitResponse(method: .GET, url: "/admin/categories/1/edit")
//        
//        XCTAssertEqual(response.http.status, .ok)
//        XCTAssertEqual(view.get("name")?.string, "Programming")
//        XCTAssertEqual(try App.Category.query(on: conn).first().wait()?.name, "Programming")
//    }
//    
//    func testCannotCreateCategoryAtAlreadyExist() throws {
//        
//        var response: Response!
//        
//        let form = DataMaker.makeCategoryFormForTest("Programming")
//        
//        response = try waitResponse(method: .POST, url: "/admin/categories") { request in
//            try request.setFormData(form, csrfToken: self.csrfToken)
//        }
//        
//        XCTAssertEqual(response.http.status, .seeOther)
//        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/admin/categories/1/edit")
//        XCTAssertEqual(try App.Category.query(on: conn).count().wait(), 1)
//        
//        response = try waitResponse(method: .POST, url: "/admin/categories") { request in
//            try request.setFormData(form, csrfToken: self.csrfToken)
//        }
//        
//        XCTAssertEqual(response.http.status, .seeOther)
//        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/admin/categories/create")
//        XCTAssertEqual(try App.Category.query(on: conn).count().wait(), 1)
//    }
//    
//    func testCanUpdateACategory() throws {
//        
//        var response: Response!
//        
//        _ = try DataMaker.makeCategory("Programming").save(on: conn).wait()
//        
//        let form = DataMaker.makeCategoryFormForTest("FX")
//        
//        response = try waitResponse(method: .POST, url: "/admin/categories/1/edit") { request in
//            try request.setFormData(form, csrfToken: self.csrfToken)
//        }
//        
//        XCTAssertEqual(response.http.status, .seeOther)
//        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/admin/categories/1/edit")
//        
//        response = try waitResponse(method: .GET, url: "/admin/categories/1/edit")
//        
//        XCTAssertEqual(response.http.status, .ok)
//        XCTAssertEqual(view.get("name")?.string, "FX")
//        XCTAssertEqual(try App.Category.query(on: conn).first().wait()?.name, "FX")
//    }
//}
//
//extension AdminCategoryControllerTests {
//    public static let allTests = [
//        ("testCanViewIndex", testCanViewIndex),
//        ("testCanViewPageButtonAtTwoPages", testCanViewPageButtonAtTwoPages),
//        ("testCanViewPageButtonAtThreePages", testCanViewPageButtonAtThreePages),
//        ("testCanViewCreateView", testCanViewCreateView),
//        ("testCanViewEditView", testCanViewEditView),
//        ("testCanDestroyACategory", testCanDestroyACategory),
//        ("testCanStoreACategory", testCanStoreACategory),
//        ("testCannotCreateCategoryAtAlreadyExist", testCannotCreateCategoryAtAlreadyExist),
//        ("testCanUpdateACategory", testCanUpdateACategory)
//    ]
//}
