@testable import App
import XCTVapor

final class AdminCategoryControllerTests: ControllerTestCase {
    
    func testCanViewIndex() throws {
        try test(.GET, "/admin/categories") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("items")?.array?.count, 0)
        }
        let category = DataMaker.makeCategory(name: "Programming")
        try category.save(on: db).wait()
        try test(.GET, "/admin/categories") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("items")?.array?.count, 1)
            XCTAssertEqual(view.get("metadata.total")?.int, 1)
            XCTAssertEqual(view.get("metadata.page")?.int, 1)
            XCTAssertEqual(view.get("metadata.totalPage")?.int, 1)
        }
    }
    
    func testCanViewPageButtonAtTwoPages() throws {
        try (1...11).forEach { i in
            let category = DataMaker.makeCategory(name: String(i))
            try category.save(on: db).wait()
        }
        try test(.GET, "/admin/categories") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("metadata.total")?.int, 11)
            XCTAssertEqual(view.get("metadata.page")?.int, 1)
            XCTAssertEqual(view.get("metadata.totalPage")?.int, 2)
        }
        try test(.GET, "/admin/categories?page=2") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("metadata.total")?.int, 11)
            XCTAssertEqual(view.get("metadata.page")?.int, 2)
            XCTAssertEqual(view.get("metadata.totalPage")?.int, 2)
        }
    }
    
    func testCanViewCreateView() throws {
        try test(.GET, "/admin/categories/create") { response in
            XCTAssertEqual(response.status, .ok)
        }
    }
    
    func testCanViewEditView() throws {
        let category = DataMaker.makeCategory(name: "Programming")
        try category.save(on: db).wait()
        try test(.GET, "/admin/categories/1/edit") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("name")?.string, "Programming")
        }
    }
    
    func testCanDestroyACategory() throws {
        let category = DataMaker.makeCategory(name: "Programming")
        try category.save(on: db).wait()
        try test(.POST, "/admin/categories/delete", body: "categories[]=1") { response in
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers.first(name: .location), "/admin/categories")
        }
        try test(.GET, "/admin/categories") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("items")?.array?.count, 0)
        }
    }
    
    func testCanStoreACategory() throws {
        try test(.POST, "/admin/categories", body: "name=Programming") { response in
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers.first(name: .location), "/admin/categories/1/edit")
        }
        try test(.GET, "/admin/categories/1/edit") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("name")?.string, "Programming")
        }
    }
    
    func testCannotStoreInvalidNameCategory() throws {
        try test(.POST, "/admin/categories", body: "name=") { response in
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers.first(name: .location), "/admin/categories/create")
        }
        try test(.GET, "/admin/categories/create") { response in
            XCTAssertNotNil(view.get("errorMessage"))
        }
        let longName = String(repeating: "a", count: 33)
        try test(.POST, "/admin/categories", body: "name=\(longName)") { response in
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers.first(name: .location), "/admin/categories/create")
        }
        try test(.GET, "/admin/categories/create") { response in
            XCTAssertNotNil(view.get("errorMessage"))
        }
    }
    
    func testCannotCreateCategoryAtAlreadyExist() throws {
        let category = DataMaker.makeCategory(name: "Programming")
        try category.save(on: db).wait()
        try test(.POST, "/admin/categories", body: "name=Programming") { response in
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers.first(name: .location), "/admin/categories/create")
        }
    }
    
    func testCanUpdateACategory() throws {
        let category = DataMaker.makeCategory(name: "Programming")
        try category.save(on: db).wait()
        try test(.POST, "/admin/categories/1/edit", body: "name=FX") { response in
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers.first(name: .location), "/admin/categories/1/edit")
        }
        try test(.GET, "/admin/categories/1/edit") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("name")?.string, "FX")
        }
    }
    
    func testCannotUpdateToInvalidNameCategory() throws {
        let category = DataMaker.makeCategory(name: "Programming")
        try category.save(on: db).wait()
        let longName = String(repeating: "a", count: 33)
        try test(.POST, "/admin/categories/1/edit", body: "name=\(longName)") { response in
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers.first(name: .location), "/admin/categories/1/edit")
        }
        try test(.GET, "/admin/categories/1/edit") { response in
            XCTAssertNotNil(view.get("errorMessage"))
        }
        XCTAssertEqual(try Category.find(1, on: db).wait()?.name, "Programming")
    }
}
