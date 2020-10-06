@testable import App
import XCTVapor

final class LoginControllerTests: ControllerTestCase {
    
    override func buildApp() -> Application {
        return try! ApplicationBuilder.build()
    }
    
    func testCanCreateRootUser() throws {
        
        let count = try User.query(on: db).all().wait().count
        let rootUser = try User.query(on: db).all().wait().first
        
        XCTAssertEqual(count, 1)
        XCTAssertEqual(rootUser?.name, "root")
    }
    
    func testCanViewIndex() throws {
        try test(.GET, "/login") { response in
            XCTAssertEqual(response.status, .ok)
        }
    }
    
    func testCanLogin() throws {
        let hashedPassword = try Bcrypt.hash("passwd", cost: 12)
        try User(name: "login", password: hashedPassword).save(on: db).wait()
        try test(.POST, "/login", body: "name=login&password=passwd", withCSRFToken: false) { response in
            XCTAssertEqual(response.status, .forbidden)
        }
        try test(.POST, "/login", body: "name=login&password=passwd") { response in
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers.first(name: .location), "/admin/posts")
        }
        try test(.GET, "admin/posts") { response in
            XCTAssertEqual(response.status, .ok)
        }
        try test(.GET, "/logout") { response in
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers.first(name: .location), "/login")
        }
        try test(.GET, "admin/posts") { response in
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers.first(name: .location), "/login")
        }
    }
    
    func testCannotLoginNoPassword() throws {
        let hashedPassword = try Bcrypt.hash("passwd", cost: 12)
        try User(name: "login", password: hashedPassword).save(on: db).wait()
        try test(.POST, "/login", body: "name=login&password=") { response in
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers.first(name: .location), "/login")
        }
    }
}

extension LoginControllerTests {
    public static let allTests = [
        ("testCanCreateRootUser", testCanCreateRootUser),
        ("testCanViewIndex", testCanViewIndex),
        ("testCanLogin", testCanLogin),
        ("testCannotLoginNoPassword", testCannotLoginNoPassword)
    ]
}