@testable import App
import XCTest
import HTTP

final class ValidationTests: ModelTestCase {
    
    func testCanValidatePostRegistration() throws {

        XCTAssertNoThrow(try DataMaker.makePost(title: "1", content: "content", isStatic: true, categoryId: nil))
        XCTAssertNoThrow(try DataMaker.makePost(title: String(repeating: "1", count: 128), content: "content", isStatic: true, categoryId: nil))
        XCTAssertThrowsError(try DataMaker.makePost(title: "", content: "content", isStatic: true, categoryId: nil))
        XCTAssertThrowsError(try DataMaker.makePost(title: String(repeating: "1", count: 129), content: "content", isStatic: true, categoryId: nil))
        
        XCTAssertThrowsError(try DataMaker.makePost(title: "1", content: "", isStatic: true, categoryId: nil))
        XCTAssertThrowsError(try DataMaker.makePost(title: "1", content: String(repeating: "1", count: 8193), isStatic: true, categoryId: nil))
    }
    
    func testCanValidatePostUpdate() throws {
        
        let post = try DataMaker.makePost(title: "1", content: "content", isStatic: true, categoryId: nil)
        
        XCTAssertNoThrow(try post.update(for: DataMaker.makePostRequest(title: "1", content: "content", isStatic: true, categoryId: nil)))
        XCTAssertNoThrow(try post.update(for: DataMaker.makePostRequest(title: String(repeating: "1", count: 128), content: "content", isStatic: true, categoryId: nil)))
        XCTAssertThrowsError(try post.update(for: DataMaker.makePostRequest(title: "", content: "content", isStatic: true, categoryId: nil)))
        XCTAssertThrowsError(try post.update(for: DataMaker.makePostRequest(title: String(repeating: "1", count: 129), content: "content", isStatic: true, categoryId: nil)))
        
        XCTAssertThrowsError(try post.update(for: DataMaker.makePostRequest(title: "1", content: "", isStatic: true, categoryId: nil)))
        XCTAssertThrowsError(try post.update(for: DataMaker.makePostRequest(title: "1", content: String(repeating: "1", count: 8193), isStatic: true, categoryId: nil)))
    }
    
    func testCanValidateTagRegistration() throws {
        
        XCTAssertNoThrow(try DataMaker.makeTag("1"))
        XCTAssertNoThrow(try DataMaker.makeTag(String(repeating: "1", count: 16)))
        XCTAssertThrowsError(try DataMaker.makeTag(""))
        XCTAssertThrowsError(try DataMaker.makeTag(String(repeating: "1", count: 17)))
    }
    
    func testCanValidateTagUpdate() throws {
        
        let tag = try DataMaker.makeTag("1")
        
        XCTAssertNoThrow(try tag.update(for: DataMaker.makeTagRequest("1")))
        XCTAssertNoThrow(try tag.update(for: DataMaker.makeTagRequest(String(repeating: "1", count: 16))))
        XCTAssertThrowsError(try tag.update(for: DataMaker.makeTagRequest("")))
        XCTAssertThrowsError(try tag.update(for: DataMaker.makeTagRequest(String(repeating: "1", count: 17))))
    }
    
    func testCanValidateCategoryRegistration() throws {
        
        XCTAssertNoThrow(try DataMaker.makeCategory("1"))
        XCTAssertNoThrow(try DataMaker.makeCategory(String(repeating: "1", count: 32)))
        XCTAssertThrowsError(try DataMaker.makeCategory(""))
        XCTAssertThrowsError(try DataMaker.makeCategory(String(repeating: "1", count: 33)))
    }
    
    func testCanValidateCategoryUpdate() throws {
        
        let category = try DataMaker.makeCategory("1")
        
        XCTAssertNoThrow(try category.update(for: DataMaker.makeTagRequest("1")))
        XCTAssertNoThrow(try category.update(for: DataMaker.makeTagRequest(String(repeating: "1", count: 32))))
        XCTAssertThrowsError(try category.update(for: DataMaker.makeTagRequest("")))
        XCTAssertThrowsError(try category.update(for: DataMaker.makeTagRequest(String(repeating: "1", count: 33))))
    }
    
    func testCanValidateSiteInfoUpdate() throws {
        
        let siteInfo = try SiteInfo.shared()
        
        XCTAssertNoThrow(try siteInfo.update(for: DataMaker.makeSiteInfoRequest(name: "1", description: "description")))
        XCTAssertNoThrow(try siteInfo.update(for: DataMaker.makeSiteInfoRequest(name: String(repeating: "1", count: 32), description: "description")))
        XCTAssertThrowsError(try siteInfo.update(for: DataMaker.makeSiteInfoRequest(name: "", description: "description")))
        XCTAssertThrowsError(try siteInfo.update(for: DataMaker.makeSiteInfoRequest(name: String(repeating: "1", count: 33), description: "description")))
        
        XCTAssertNoThrow(try siteInfo.update(for: DataMaker.makeSiteInfoRequest(name: "1", description: String(repeating: "1", count: 128))))
        XCTAssertThrowsError(try siteInfo.update(for: DataMaker.makeSiteInfoRequest(name: "1", description: String(repeating: "1", count: 129))))
    }
}

extension ValidationTests {
    public static let allTests = [
        ("testCanValidatePostRegistration", testCanValidatePostRegistration),
        ("testCanValidatePostUpdate", testCanValidatePostUpdate),
        ("testCanValidateTagRegistration", testCanValidateTagRegistration),
        ("testCanValidateTagUpdate", testCanValidateTagUpdate),
        ("testCanValidateCategoryRegistration", testCanValidateCategoryRegistration),
        ("testCanValidateCategoryUpdate", testCanValidateCategoryUpdate),
        ("testCanValidateSiteInfoUpdate", testCanValidateSiteInfoUpdate)
    ]
}