@testable import App
import Cookies
import HTTP
import Swinject
import Vapor
import XCTest

final class APIThemeControllerTests: ControllerTestCase {
    
    struct RepositoryAssembly: Assembly {
        
        func assemble(container: Container) {
            
            container.register(FileRepository.self) { _ in
                return TestThemeRepository()
            }.inObjectScope(.container)
        }
    }
    
    override func setUp() {
        super.setUp()
        App.register(assembly: RepositoryAssembly())
    }

    func testCanViewIndex() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/api/themes")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
    }
    
    func testCanRespondOnStore() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .post, uri: "/api/themes")
        request.cookies.insert(requestData.cookie)
        try request.setJSONData(["name": "Theme1"], requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
    }
    
    func testCannotContinueStoreOnInvalidParams() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .post, uri: "/api/themes")
        request.cookies.insert(requestData.cookie)
        try request.setJSONData([:], requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .badRequest)
    }
    
    func testCanRespondOnApply() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .post, uri: "/api/themes/apply")
        request.cookies.insert(requestData.cookie)
        try request.setJSONData(["name": "Theme1"], requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
    }
    
    func testCannotContinueApplyOnInvalidParams() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .post, uri: "/api/themes/apply")
        request.cookies.insert(requestData.cookie)
        try request.setJSONData([:], requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .badRequest)
    }
    
    func testCanRespondOnDelete() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .post, uri: "/api/themes/delete")
        request.cookies.insert(requestData.cookie)
        try request.setJSONData(["name": "Theme1"], requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
    }
    
    func testCannotContinueDeleteOnInvalidParams() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .post, uri: "/api/themes/delete")
        request.cookies.insert(requestData.cookie)
        try request.setJSONData([:], requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .badRequest)
    }
}

extension APIThemeControllerTests {
    public static let allTests = [
        ("testCanViewIndex", testCanViewIndex),
        ("testCanRespondOnStore", testCanRespondOnStore),
        ("testCannotContinueStoreOnInvalidParams", testCannotContinueStoreOnInvalidParams),
        ("testCanRespondOnApply", testCanRespondOnApply),
        ("testCannotContinueApplyOnInvalidParams", testCannotContinueApplyOnInvalidParams),
        ("testCanRespondOnDelete", testCanRespondOnDelete),
        ("testCannotContinueDeleteOnInvalidParams", testCannotContinueDeleteOnInvalidParams)
    ]
}