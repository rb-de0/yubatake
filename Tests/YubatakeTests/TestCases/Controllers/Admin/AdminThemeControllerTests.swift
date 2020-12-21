@testable import App
import XCTVapor

final class AdminThemeControllerTests: ControllerTestCase {
    
    func testCanViewIndex() throws {
        try test(.GET, "/admin/themes", afterResponse:  { response in
            XCTAssertEqual(response.status, .ok)
        })
    }
}

extension AdminThemeControllerTests {
    public static let allTests = [
        ("testCanViewIndex", testCanViewIndex)
    ]
}
