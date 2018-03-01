@testable import App
import HTTP
import Swinject
import Vapor
import XCTest

final class AdminImageControllerTests: ControllerTestCase {
    
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
        
        let image = try DataMaker.makeImage("favicon")
        try image.0.save()
        try image.1.save()
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/admin/images")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual((view.get("data") as Node?)?.array?.count, 1)
        XCTAssertEqual(view.get("has_not_found"), false)
    }
    
    func testCanViewCleanButtonWhenHasNotFound() throws {
        
        let image = try DataMaker.makeImage("favicon")
        try image.1.save()
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/admin/images")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(view.get("has_not_found"), true)
    }
    
    func testCanViewEditView() throws {
        
        let image = try DataMaker.makeImage("favicon")
        try image.0.save()
        try image.1.save()
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/admin/images/1/edit")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
    }
    
    func testCanCleanUp() throws {
        
        let image1 = try DataMaker.makeImage("favicon")
        try image1.1.save()
        
        let image2 = try DataMaker.makeImage("sample")
        try image2.0.save()
        try image2.1.save()
        
        XCTAssertEqual(try Image.count(), 2)
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .post, uri: "/admin/images/cleanup")
        request.cookies.insert(requestData.cookie)
        try request.setFormData([:], requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/admin/images")
        XCTAssertEqual(try Image.count(), 1)
        XCTAssertEqual(try Image.all().first?.path, "/documents/imgs/sample")
    }
    
    func testCanDestroyAImage() throws {
        
        let image = try DataMaker.makeImage("favicon")
        try image.0.save()
        try image.1.save()
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/admin/images")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual((view.get("data") as Node?)?.array?.count, 1)
        
        let json: JSON = ["images": [1]]
        request = Request(method: .post, uri: "/admin/images/delete")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/admin/images")
        XCTAssertEqual(try Image.count(), 0)
    }
    
    // MARK: - Store/Update
    
    func testCanStoreAImage() throws {
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        let json = DataMaker.makeImageDataJSON(name: "favicon")
        
        request = Request(method: .post, uri: "/admin/images")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/admin/images")
        XCTAssertEqual(try Image.count(), 1)
        XCTAssertTrue(resolve(FileRepository.self).isExistPublicResource(path: "/documents/imgs/favicon"))
    }
    
    func testCanUpdateAImage() throws {
        
        let image = try DataMaker.makeImage("favicon")
        try image.0.save()
        try image.1.save()
        
        let requestData = try login()
        
        var request: Request!
        var response: Response!
        
        request = Request(method: .get, uri: "/admin/images/1/edit")
        request.cookies.insert(requestData.cookie)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(view.get("path"), "/documents/imgs/favicon")
        XCTAssertEqual(try Image.find(1)?.path, "/documents/imgs/favicon")
        XCTAssertTrue(resolve(FileRepository.self).isExistPublicResource(path: "/documents/imgs/favicon"))
        
        let json = DataMaker.makeImageJSON(path: "/documents/imgs/sample")
        
        request = Request(method: .post, uri: "/admin/images/1/edit")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, requestData.csrfToken)
        response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/admin/images/1/edit")
        XCTAssertEqual(try Image.find(1)?.path, "/documents/imgs/sample")
        XCTAssertTrue(resolve(FileRepository.self).isExistPublicResource(path: "/documents/imgs/sample"))
    }
}

extension AdminImageControllerTests {
    public static let allTests = [
        ("testCanViewIndex", testCanViewIndex),
        ("testCanViewCleanButtonWhenHasNotFound", testCanViewCleanButtonWhenHasNotFound),
        ("testCanViewEditView", testCanViewEditView),
        ("testCanCleanUp", testCanCleanUp),
        ("testCanDestroyAImage", testCanDestroyAImage),
        ("testCanStoreAImage", testCanStoreAImage),
        ("testCanUpdateAImage", testCanUpdateAImage)
    ]
}
