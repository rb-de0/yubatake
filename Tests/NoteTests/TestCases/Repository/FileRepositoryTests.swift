@testable import App
import Vapor
import XCTest
import Foundation

final class FileRepositoryTests: FileHandleTestCase {
    
    func testCanGetAccessibleFilesOriginalOnlyNoTheme() throws {
        
        let repository = FileRepositoryImpl()
        
        let groups = repository.files(in: nil)
        
        XCTAssertEqual(groups.count, 3)
        
        for group in groups {
            XCTAssertEqual(group.files.count, 1)
        }
    }
    
    func testCanCreateUserData() throws {
        
        var updated = ""
        
        let repository = FileRepositoryImpl()
        try repository.writeUserFileData(at: "/js/test.js", type: .publicResource, data: "JavaScriptTestCodeUpdated")
        updated = try repository.readFileData(at: "/user/js/test.js", type: .publicResource)
        
        XCTAssertEqual(updated, "JavaScriptTestCodeUpdated")
        XCTAssertNoThrow(try repository.readUserFileData(at: "/js/test.js", type: .publicResource))
        
        try repository.writeUserFileData(at: "/styles/test.css", type: .publicResource, data: "CSSTestStyleUpdated")
        updated = try repository.readFileData(at: "/user/styles/test.css", type: .publicResource)
        
        XCTAssertEqual(updated, "CSSTestStyleUpdated")
        XCTAssertNoThrow(try repository.readUserFileData(at: "/styles/test.css", type: .publicResource))
        
        try repository.writeUserFileData(at: "/test/test.leaf", type: .view, data: "LeafTestTemplateUpdated")
        updated = try repository.readFileData(at: "/user/test/test.leaf", type: .view)
        
        XCTAssertEqual(updated, "LeafTestTemplateUpdated")
        XCTAssertNoThrow(try repository.readUserFileData(at: "/test/test.leaf", type: .view))
    }
    
    func testCanDeleteUserData() throws {
        
        let repository = FileRepositoryImpl()
        try repository.writeUserFileData(at: "/js/test.js", type: .publicResource, data: "JavaScriptTestCodeUpdated")
        try repository.deleteUserFileData(at: "/js/test.js", type: .publicResource)
        
        XCTAssertThrowsError(try repository.readUserFileData(at: "/js/test.js", type: .publicResource))
        
        try repository.writeUserFileData(at: "/styles/test.css", type: .publicResource, data: "CSSTestStyleUpdated")
        try repository.deleteUserFileData(at: "/styles/test.css", type: .publicResource)
        
        XCTAssertThrowsError(try repository.readUserFileData(at: "/styles/test.css", type: .publicResource))
        
        try repository.writeUserFileData(at: "/test/test.leaf", type: .view, data: "LeafTestTemplateUpdated")
        try repository.deleteUserFileData(at: "/test/test.leaf", type: .view)
        
        XCTAssertThrowsError(try repository.readUserFileData(at: "/test/test.leaf", type: .publicResource))
    }
    
    func testCanViewNotFound() throws {
        
        let repository = FileRepositoryImpl()
        
        do {
            _ = try repository.readFileData(at: "/js/not_found.js", type: .publicResource)
            XCTFail()
        } catch let error as Abort where error.status == .notFound {
            XCTAssertTrue(true)
        }
    }
}
