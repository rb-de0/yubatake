@testable import App
import Vapor
import XCTest

final class ValidationTests: ControllerTestCase {
    
    func testCanValidatePostRegistration() throws {
        
        XCTAssertNoThrow(try DataMaker.makePost(title: "1", content: "1", categoryId: nil, isStatic: true, on: app, conn: conn))
        XCTAssertNoThrow(try DataMaker.makePost(title: String(repeating: "1", count: 128), content: String(repeating: "1", count: 8192), categoryId: nil, isStatic: true, on: app, conn: conn))
        canThrowValidateError(try DataMaker.makePost(title: "", content: "1", categoryId: nil, isStatic: true, on: app, conn: conn))
        canThrowValidateError(try DataMaker.makePost(title: String(repeating: "1", count: 129), content: "content", categoryId: nil, isStatic: true, on: app, conn: conn))
        
        canThrowValidateError(try DataMaker.makePost(title: "1", content: "", categoryId: nil, isStatic: true, on: app, conn: conn))
        canThrowValidateError(try DataMaker.makePost(title: "1", content: String(repeating: "1", count: 8193), categoryId: nil, isStatic: true, on: app, conn: conn))
    }
    
    func testCanValidatePostUpdate() throws {
        
        let post = try DataMaker.makePost(title: "1", content: "1", categoryId: nil, isStatic: true, on: app, conn: conn)
        let request = try DataMaker.makeAuthorizedRequest(on: app, conn: conn)
        var form: PostForm
        
        form = try DataMaker.makePostForm(title: "1", content: "1", categoryId: nil, isStatic: true, isPublished: true)
        XCTAssertNoThrow(try post.apply(form: form, on: request))
        form = try DataMaker.makePostForm(title: String(repeating: "1", count: 128), content: String(repeating: "1", count: 8192), categoryId: nil, isStatic: true, isPublished: true)
        XCTAssertNoThrow(try post.apply(form: form, on: request))
        
        form = try DataMaker.makePostForm(title: "", content: "1", categoryId: nil, isStatic: true, isPublished: true)
        canThrowValidateError(try post.apply(form: form, on: request))
        form = try DataMaker.makePostForm(title: String(repeating: "1", count: 129), content: "1", categoryId: nil, isStatic: true, isPublished: true)
        canThrowValidateError(try post.apply(form: form, on: request))
        
        form = try DataMaker.makePostForm(title: "1", content: "", categoryId: nil, isStatic: true, isPublished: true)
        canThrowValidateError(try post.apply(form: form, on: request))
        form = try DataMaker.makePostForm(title: "1", content: String(repeating: "1", count: 8193), categoryId: nil, isStatic: true, isPublished: true)
        canThrowValidateError(try post.apply(form: form, on: request))
    }
    
    func testCanValidateTagRegistration() throws {
        
        XCTAssertNoThrow(try DataMaker.makeTag("1"))
        XCTAssertNoThrow(try DataMaker.makeTag(String(repeating: "1", count: 16)))
        
        canThrowValidateError(try DataMaker.makeTag(""))
        canThrowValidateError(try DataMaker.makeTag(String(repeating: "1", count: 17)))
    }
    
    func testCanValidateTagUpdate() throws {
        
        let tag = try DataMaker.makeTag("1")
        
        XCTAssertNoThrow(try tag.apply(form: TagForm(name: "1")))
        XCTAssertNoThrow(try tag.apply(form: TagForm(name: String(repeating: "1", count: 16))))
        canThrowValidateError(try tag.apply(form: TagForm(name: "")))
        canThrowValidateError(try tag.apply(form: TagForm(name: String(repeating: "1", count: 17))))
    }
    
    func testCanValidateCategoryRegistration() throws {
        
        XCTAssertNoThrow(try DataMaker.makeCategory("1"))
        XCTAssertNoThrow(try DataMaker.makeCategory(String(repeating: "1", count: 32)))
        
        canThrowValidateError(try DataMaker.makeCategory(""))
        canThrowValidateError(try DataMaker.makeCategory(String(repeating: "1", count: 33)))
    }
    
    func testCanValidateCategoryUpdate() throws {
        
        let category = try DataMaker.makeCategory("1")
        
        XCTAssertNoThrow(try category.apply(form: CategoryForm(name: "1")))
        XCTAssertNoThrow(try category.apply(form: CategoryForm(name: String(repeating: "1", count: 32))))
        canThrowValidateError(try category.apply(form: CategoryForm(name: "")))
        canThrowValidateError(try category.apply(form: CategoryForm(name: String(repeating: "1", count: 33))))
    }
    
    func testCanValidateSiteInfoUpdate() throws {
        
        let siteInfo = try SiteInfo.shared(on: conn).wait()
        
        XCTAssertNoThrow(try siteInfo.apply(form: SiteInfoForm(name: "1", description: "1")))
        XCTAssertNoThrow(try siteInfo.apply(form: SiteInfoForm(name: String(repeating: "1", count: 32), description: String(repeating: "1", count: 128))))
        
        canThrowValidateError(try siteInfo.apply(form: SiteInfoForm(name: "", description: "1")))
        canThrowValidateError(try siteInfo.apply(form: SiteInfoForm(name: String(repeating: "1", count: 33), description: "1")))
        canThrowValidateError(try siteInfo.apply(form: SiteInfoForm(name: "1", description: String(repeating: "1", count: 129))))
    }
    
    func testCanValidateUserUpdate() throws {
        
        let user = try User.find(1, on: conn).unwrap(or: TestError.unexpected).wait()
        var form: UserForm
        
        form = UserForm(name: "1", password: "1", apiKey: nil, apiSecret: nil, accessToken: nil, accessTokenSecret: nil)
        XCTAssertNoThrow(try user.apply(form: form, on: app).wait())
        form = UserForm(name: String(repeating: "1", count: 32), password: "1", apiKey: nil, apiSecret: nil, accessToken: nil, accessTokenSecret: nil)
        XCTAssertNoThrow(try user.apply(form: form, on: app).wait())
        form = UserForm(name: String(repeating: "1", count: 33), password: "1", apiKey: nil, apiSecret: nil, accessToken: nil, accessTokenSecret: nil)
        canThrowValidateError(try user.apply(form: form, on: app).wait())
    }
    
    private func canThrowValidateError<T>(_ expression: @autoclosure () throws -> T) {
        
        do {
            _ = try expression()
            XCTFail("No throw")
        } catch {
            XCTAssertTrue(error is ValidationError)
        }
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
        ("testCanValidateSiteInfoUpdate", testCanValidateSiteInfoUpdate),
        ("testCanValidateUserUpdate", testCanValidateUserUpdate)
    ]
}