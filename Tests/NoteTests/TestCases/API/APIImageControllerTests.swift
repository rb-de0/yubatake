@testable import App
import Cookies
import HTTP
import Swinject
import Vapor
import XCTest

final class APIImageControllerTests: ControllerTestCase {
    
    struct RepositoryAssembly: Assembly {
        
        func assemble(container: Container) {
            container.register(FileRepository.self) { _ in
                return TestImageFileRepository()
            }.inObjectScope(.container)
        }
    }
    
    override func setUp() {
        super.setUp()
        App.register(assembly: RepositoryAssembly())
        TestImageFileRepository.imageFiles.removeAll()
    }
    
    func testCanViewIndex() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/api/images")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        
        let image = try DataMaker.makeImage("favicon")
        try image.0.save()
        try image.1.save()
        
        request = Request(method: .get, uri: "/api/images")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        
        let responseJSON = response.json
        
        XCTAssertEqual(try responseJSON?.get("page.position.max"), 1)
        XCTAssertEqual(try responseJSON?.get("page.position.current"), 1)
        XCTAssertNil(try responseJSON?.get("page.position.next"))
        XCTAssertNil(try responseJSON?.get("page.position.previous"))
        XCTAssertEqual((try responseJSON?.get("data") as Node?)?.array?.count, 1)
    }
}

extension APIImageControllerTests {
    public static let allTests = [
        ("testCanViewIndex", testCanViewIndex)
    ]
}