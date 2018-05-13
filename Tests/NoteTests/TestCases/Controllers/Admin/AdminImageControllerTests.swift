@testable import App
import Vapor
import XCTest

final class AdminImageControllerTests: ControllerTestCase, AdminTestCase {
    
    override func buildApp() throws -> Application {
        var config = Config.default()
        var services = Services.default()
        services.register(TestImageFileRepository(), as: ImageRepository.self)
        config.prefer(TestImageFileRepository.self, for: ImageRepository.self)
        return try ApplicationBuilder.build(forAdminTests: true, configForTest: config, servicesForTest: services)
    }
    
    override func setUp() {
        super.setUp()
        TestImageFileRepository.imageFiles.removeAll()
    }
    
    func testCanViewIndex() throws {

        let repository = try app.make(ImageRepository.self)
        
        let image = try DataMaker.makeImage("favicon", on: app)
        let form = image.0
        let imageModel = image.1
        
        try repository.save(image: form.data, for: form.name)
        _ = try imageModel.save(on: conn).wait()
        
        let response = try waitResponse(method: .GET, url: "/admin/images")
        
        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(view.get("has_not_found")?.bool, false)
    }
    
    func testCanViewCleanButtonWhenHasNotFound() throws {
        
        let image = try DataMaker.makeImage("favicon", on: app)
        let imageModel = image.1
        
        _ = try imageModel.save(on: conn).wait()
        
        let response = try waitResponse(method: .GET, url: "/admin/images")
        
        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(view.get("has_not_found")?.bool, true)
    }
    
    func testCanViewEditView() throws {
        
        let repository = try app.make(ImageRepository.self)
        
        let image = try DataMaker.makeImage("favicon", on: app)
        let form = image.0
        let imageModel = image.1
        
        try repository.save(image: form.data, for: form.name)
        _ = try imageModel.save(on: conn).wait()
        
        let response = try waitResponse(method: .GET, url: "/admin/images/1/edit")
        
        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(view.get("path")?.string, "/documents/imgs/favicon")
        XCTAssertEqual(try Image.query(on: conn).first().wait()?.path, "/documents/imgs/favicon")
    }
    
    func testCanCleanUp() throws {

        let repository = try app.make(ImageRepository.self)
        
        let image1 = try DataMaker.makeImage("favicon", on: app)
        let imageModel1 = image1.1
        
        let image2 = try DataMaker.makeImage("sample", on: app)
        let form2 = image2.0
        let imageModel2 = image2.1
        
        _ = try imageModel1.save(on: conn).wait()
        
        try repository.save(image: form2.data, for: form2.name)
        _ = try imageModel2.save(on: conn).wait()
        
        let response = try waitResponse(method: .POST, url: "/admin/images/cleanup") { request in
            try request.setFormData([String: String](), csrfToken: self.csrfToken)
        }
        
        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/admin/images")
        XCTAssertEqual(try Image.query(on: conn).count().wait(), 1)
        XCTAssertEqual(try Image.query(on: conn).first().wait()?.path, "/documents/imgs/sample")
    }
    
    func testCanDestroyAImage() throws {

        let repository = try app.make(ImageRepository.self)
        
        let image = try DataMaker.makeImage("favicon", on: app)
        let form = image.0
        let imageModel = image.1
        
        try repository.save(image: form.data, for: form.name)
        _ = try imageModel.save(on: conn).wait()
        
        var response: Response!
        
        response = try waitResponse(method: .GET, url: "/admin/images")
        
        XCTAssertEqual(response.http.status, .ok)
        
        response = try waitResponse(method: .POST, url: "/admin/images/1/delete") { request in
            try request.setFormData([String: String](), csrfToken: self.csrfToken)
        }
        
        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/admin/images")
        XCTAssertEqual(try Image.query(on: conn).count().wait(), 0)
    }
    
    // MARK: - Store/Update
    
    func testCanUpdateAImage() throws {

        let repository = try app.make(ImageRepository.self)
        
        var response: Response!
        
        let image = try DataMaker.makeImage("favicon", on: app)
        let form = image.0
        let imageModel = image.1
        
        try repository.save(image: form.data, for: form.name)
        _ = try imageModel.save(on: conn).wait()
        
        let updateForm = DataMaker.makeImageFormForTest(name: "sample", altDescription: "sample_description")
        
        response = try waitResponse(method: .POST, url: "/admin/images/1/edit") { request in
            try request.setFormData(updateForm, csrfToken: self.csrfToken)
        }
        
        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers.firstValue(name: .location), "/admin/images/1/edit")
        XCTAssertEqual(try Image.query(on: conn).first().wait()?.path, "/documents/imgs/sample")
        
        response = try waitResponse(method: .GET, url: "/admin/images/1/edit")
        
        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(view.get("path")?.string, "/documents/imgs/sample")
        XCTAssertEqual(try Image.query(on: conn).first().wait()?.path, "/documents/imgs/sample")
    }
}

extension AdminImageControllerTests {
    public static let allTests = [
        ("testCanViewIndex", testCanViewIndex),
        ("testCanViewCleanButtonWhenHasNotFound", testCanViewCleanButtonWhenHasNotFound),
        ("testCanViewEditView", testCanViewEditView),
        ("testCanCleanUp", testCanCleanUp),
        ("testCanDestroyAImage", testCanDestroyAImage),
        ("testCanUpdateAImage", testCanUpdateAImage)
    ]
}
