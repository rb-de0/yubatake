@testable import App
import XCTVapor

final class AdminUserControllerTests: ControllerTestCase {
    
    func testCanViewCreateView() throws {
        try test(.GET, "/admin/user/edit") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("name")?.string, "root")
            XCTAssertNil(view.get("password"))
        }
    }
    
    func testCanUpdateAUser() throws {
        try test(.POST, "/admin/user/edit", body: "name=rb_de0&password=123456789") { response in
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers.first(name: .location), "/admin/user/edit")
        }
        let user = try User.query(on: db).first().wait()
        XCTAssertEqual(user?.name, "rb_de0")
        XCTAssert(try Bcrypt.verify("123456789", created: (user?.password ?? "")))
    }
    
    func testCannotUpdateInvalidFormData() throws {
        do {
            try test(.POST, "/admin/user/edit", body: "name=&password=123456789") { response in
                XCTAssertEqual(response.status, .seeOther)
                XCTAssertEqual(response.headers.first(name: .location), "/admin/user/edit")
            }
            try test(.GET, "/admin/user/edit") { response in
                XCTAssertNotNil(view.get("errorMessage"))
            }
            let user = try User.query(on: db).first().wait()
            XCTAssertEqual(user?.name, "root")
            XCTAssertFalse(try Bcrypt.verify("123456789", created: (user?.password ?? "")))
        }
        do {
            try test(.POST, "/admin/user/edit", body: "name=rb_de0&password=") { response in
                XCTAssertEqual(response.status, .seeOther)
                XCTAssertEqual(response.headers.first(name: .location), "/admin/user/edit")
            }
            try test(.GET, "/admin/user/edit") { response in
                XCTAssertNotNil(view.get("errorMessage"))
            }
            let user = try User.query(on: db).first().wait()
            XCTAssertEqual(user?.name, "root")
            XCTAssertFalse(try Bcrypt.verify("123456789", created: (user?.password ?? "")))
        }
        do {
            let longName = String(repeating: "a", count: 33)
            try test(.POST, "/admin/user/edit", body: "name=\(longName)&password=123456789") { response in
                XCTAssertEqual(response.status, .seeOther)
                XCTAssertEqual(response.headers.first(name: .location), "/admin/user/edit")
            }
            try test(.GET, "/admin/user/edit") { response in
                XCTAssertNotNil(view.get("errorMessage"))
            }
            let user = try User.query(on: db).first().wait()
            XCTAssertEqual(user?.name, "root")
            XCTAssertFalse(try Bcrypt.verify("123456789", created: (user?.password ?? "")))
        }
    }
}
