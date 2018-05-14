@testable import App
import Vapor
import XCTest

final class APIImageControllerTests: ControllerTestCase, AdminTestCase {
    
    override func buildApp() throws -> Application {
        return try ApplicationBuilder.build(forAdminTests: true) { (_config, _services) in
            var services = _services
            var config = _config
            services.register(TestImageFileRepository(), as: ImageRepository.self)
            config.prefer(TestImageFileRepository.self, for: ImageRepository.self)
            return (config, services)
        }
    }
    
    override func setUp() {
        super.setUp()
        TestImageFileRepository.imageFiles.removeAll()
    }
    
    func testCanViewIndex() throws {
        
        var response: Response!
        
        response = try waitResponse(method: .GET, url: "/api/images")
        
        XCTAssertEqual(response.http.status, .ok)
        
        let repository = try app.make(ImageRepository.self)
        
        let image = try DataMaker.makeImage("favicon", on: app)
        let form = image.0
        let imageModel = image.1
        
        try repository.save(image: form.data, for: form.name)
        _ = try imageModel.save(on: conn).wait()
        
        response = try waitResponse(method: .GET, url: "/api/images")
        
        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(try response.content.syncGet(at: "page", "position", "max") as Int, 1)
        XCTAssertEqual(try response.content.syncGet(at: "page", "position", "current") as Int, 1)
        XCTAssertThrowsError(try response.content.syncGet(at: "page", "position", "next") as Int)
        XCTAssertThrowsError(try response.content.syncGet(at: "page", "position", "previous") as Int)
    }
}

extension APIImageControllerTests {
    public static let allTests = [
        ("testCanViewIndex", testCanViewIndex)
    ]
}
