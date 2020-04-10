@testable import App
import XCTVapor

final class PublicFileMiddlewareTests: ControllerTestCase {
    
    override func buildApp() -> Application {
        return try! ApplicationBuilder.build()
    }
    
    func testCanRespondFiles() throws {
        try test(.GET, "/themes/default/styles/style.css") { response in
            XCTAssertEqual(response.status, .ok)
        }
        try test(.GET, "/themes/pure/js/menu.js") { response in
            XCTAssertEqual(response.status, .ok)
        }
        try test(.GET, "/js/file-editor.js") { response in
            XCTAssertEqual(response.status, .ok)
        }
    }
    
    func testCanProtectTemplateFiles() throws {
        try test(.GET, "/themes/default/template/post.leaf") { response in
            XCTAssertEqual(response.status, .notFound)
        }
    }
}
