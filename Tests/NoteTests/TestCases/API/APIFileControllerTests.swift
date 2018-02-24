@testable import App
import Cookies
import HTTP
import Swinject
import Vapor
import XCTest

final class APIFileControllerTests: ControllerTestCase {
    
    struct RepositoryAssembly: Assembly {
        
        func assemble(container: Container) {
            container.register(FileRepository.self) { _ in
                return TestFileRepository()
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
        
        request = Request(method: .get, uri: "/api/files")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
    }
    
    func testCanRespondOnStore() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .post, uri: "/api/filebody")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(["body": "test", "path": "", "type": "public"], requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        
        request = Request(method: .post, uri: "/api/filebody")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(["body": "test", "path": "", "type": "view"], requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
    }
    
    func testCannotContinueStoreOnInvalidParams() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .post, uri: "/api/filebody")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(["path": "", "type": "public"], requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .badRequest)
        
        request = Request(method: .post, uri: "/api/filebody")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(["body": "test", "type": "view"], requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .badRequest)
        
        request = Request(method: .post, uri: "/api/filebody")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(["body": "test", "path": "", "type": ""], requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .badRequest)
    }
    
    func testCanRespondOnShow() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/api/filebody")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(["path": "", "type": "public"], requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        
        request = Request(method: .get, uri: "/api/filebody")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(["path": "", "type": "view"], requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
    }
    
    func testCanRespondOnDelete() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .post, uri: "/api/filebody/delete")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(["path": "", "type": "public"], requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        
        request = Request(method: .post, uri: "/api/filebody/delete")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(["path": "", "type": "view"], requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
    }
}

extension APIFileControllerTests {
    public static let allTests = [
        ("testCanViewIndex", testCanViewIndex),
        ("testCanRespondOnStore", testCanRespondOnStore),
        ("testCannotContinueStoreOnInvalidParams", testCannotContinueStoreOnInvalidParams),
        ("testCanRespondOnShow", testCanRespondOnShow),
        ("testCanRespondOnDelete", testCanRespondOnDelete)
    ]
}