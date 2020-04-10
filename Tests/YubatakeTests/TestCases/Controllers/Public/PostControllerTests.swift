@testable import App
import XCTVapor

final class PostControllerTests: ControllerTestCase {
    
    override func buildApp() -> Application {
        return try! ApplicationBuilder.build()
    }
    
    func testCanViewIndex() throws {
        try test(.GET, "/") { response in
            XCTAssertEqual(response.status, .ok)
        }
        try test(.GET, "/posts") { response in
            XCTAssertEqual(response.status, .ok)
        }
    }
    
    func testCanViewPageButtonAtOnePage() throws {
        try (1...10).forEach { i in
            let post = DataMaker.makePost(title: "title", content: "content", htmlContent: "htmlContent", partOfContent: "partOfContent", userId: 1)
            try post.save(on: db).wait()
        }
        try test(.GET, "/posts") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("metadata.total")?.int, 10)
            XCTAssertEqual(view.get("metadata.page")?.int, 1)
            XCTAssertEqual(view.get("metadata.totalPage")?.int, 1)
        }
    }
    
    func testCanViewPageButtonAtTwoPages() throws {
        try (1...11).forEach { i in
            let post = DataMaker.makePost(title: "title", content: "content", htmlContent: "htmlContent", partOfContent: "partOfContent", userId: 1)
            try post.save(on: db).wait()
        }
        try test(.GET, "/posts") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("metadata.total")?.int, 11)
            XCTAssertEqual(view.get("metadata.page")?.int, 1)
            XCTAssertEqual(view.get("metadata.totalPage")?.int, 2)
        }
    }
    
    func testCanViewStaticContent() throws {
        let post = DataMaker.makePost(title: "title", content: "content", htmlContent: "htmlContent", partOfContent: "partOfContent", userId: 1, isStatic: true)
        try post.save(on: db).wait()
        try test(.GET, "/posts") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("items")?.array?.count, 0)
            XCTAssertEqual(view.get("staticContents")?.array?.count, 1)
        }
    }
    
    func testCannotViewDraftContent() throws {
        let post = DataMaker.makePost(title: "title", content: "content", htmlContent: "htmlContent", partOfContent: "partOfContent", userId: 1, isPublished: false)
        try post.save(on: db).wait()
        try test(.GET, "/posts") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("items")?.array?.count, 0)
            XCTAssertEqual(view.get("staticContents")?.array?.count, 0)
        }
    }
    
    func testCannotViewDraftStaticContent() throws {
        let post = DataMaker.makePost(title: "title", content: "content", htmlContent: "htmlContent", partOfContent: "partOfContent", userId: 1, isStatic: true, isPublished: false)
        try post.save(on: db).wait()
        try test(.GET, "/posts") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("items")?.array?.count, 0)
            XCTAssertEqual(view.get("staticContents")?.array?.count, 0)
        }
    }
    
    func testCanViewPostsInTags() throws {
        let tag = DataMaker.makeTag(name: "iOS")
        try tag.save(on: db).wait()
        let post = DataMaker.makePost(title: "title", content: "content", htmlContent: "htmlContent", partOfContent: "partOfContent", userId: 1)
        try post.save(on: db).wait()
        try post.$tags.attach(tag, on: db).wait()
        try test(.GET, "/tags/1/posts") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("items")?.array?.count, 1)
        }
    }
    
    func testCanViewPostsInACategory() throws {
        let category = DataMaker.makeCategory(name: "Programming")
        try category.save(on: db).wait()
        let post = DataMaker.makePost(title: "title", content: "content", htmlContent: "htmlContent", partOfContent: "partOfContent", categoryId: 1, userId: 1)
        try post.save(on: db).wait()
        try test(.GET, "/categories/1/posts") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("items")?.array?.count, 1)
        }
    }
    
    func testCanViewPostsNoCategory() throws {
        let post = DataMaker.makePost(title: "title", content: "content", htmlContent: "htmlContent", partOfContent: "partOfContent", userId: 1)
        try post.save(on: db).wait()
        try test(.GET, "/categories/noncategorized/posts") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("items")?.array?.count, 1)
        }
    }
    
    func testCanViewAPost() throws {
        let post = DataMaker.makePost(title: "title", content: "content", htmlContent: "htmlContent", partOfContent: "partOfContent", userId: 1)
        try post.save(on: db).wait()
        try test(.GET, "/posts/1") { response in
            XCTAssertEqual(response.status, .ok)
        }
        try test(.GET, "/1") { response in
            XCTAssertEqual(response.status, .ok)
        }
    }
}
