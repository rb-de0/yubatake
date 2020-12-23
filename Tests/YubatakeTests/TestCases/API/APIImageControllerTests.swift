@testable import App
import XCTVapor

final class APIImageControllerTests: ControllerTestCase {
    
    override func buildApp() -> Application {
        let app = try! ApplicationBuilder.buildForAdmin()
        app.register(imageRepository: TestImageFileRepository())
        return app
    }
    
    override func setUp() {
        super.setUp()
        TestImageFileRepository.imageFiles.removeAll()
    }
    
    func testCanViewIndex() throws {
        try app.imageRepository.save(image: "image".data(using: .utf8)!, for: "favicon")
        let image = DataMaker.makeImage(path: "/documents/imgs/favicon", altDescription: "favicon")
        try image.save(on: db).wait()
        try test(.GET, "/api/images", afterResponse:  { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(try response.content.get(at: "metadata", "page") as Int, 1)
            XCTAssertEqual(try response.content.get(at: "metadata", "total") as Int, 1)
            XCTAssertEqual(try response.content.get(at: "metadata", "totalPage") as Int, 1)
        })
    }
}
    

extension APIImageControllerTests {
    public static let allTests = [
        ("testCanViewIndex", testCanViewIndex)
    ]
}
