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
    
    // MARK: - Theme
    
    func testCanGetFilesInATheme() throws {
        
        let repository = FileRepositoryImpl()
        let groups = repository.files(in: "Theme1")
        
        XCTAssertEqual(groups.count, 2)
    }
    
    func testCanGetAllThemes() throws {
        
        let repository = FileRepositoryImpl()
        let themes = try repository.getAllThemes()
        
        XCTAssertEqual(themes.count, 2)
        XCTAssertTrue("Theme1-Theme2".contains(themes.joined(separator: "-")) || "Theme2-Theme1".contains(themes.joined(separator: "-")))
    }
    
    func testCanSaveTheme() throws {
        
        let repository = FileRepositoryImpl()
        try repository.writeUserFileData(at: "/js/test.js", type: .publicResource, data: "JavaScriptTestCodeForTheme3")
        try repository.saveTheme(as: "Theme3")
        
        let themes = try repository.getAllThemes()
        
        XCTAssertEqual(themes.count, 3)
        
        let code = try repository.readThemeFileData(in: "Theme3", at: "/js/test.js", type: .publicResource)
        XCTAssertEqual(code, "JavaScriptTestCodeForTheme3")
    }
    
    func testCanCopyTheme() throws {
        
        let repository = FileRepositoryImpl()
        try repository.copyTheme(name: "Theme1")
        
        let jsCode = try repository.readFileData(at: "/user/js/test.js", type: .publicResource)
        XCTAssertEqual(jsCode, "JavaScriptTestCodeForTheme1")
        
        let leafCode = try repository.readFileData(at: "/user/test.leaf", type: .view)
        XCTAssertEqual(leafCode, "LeafTestTemplateForTheme1")
    }
    
    func testCanDeleteTheme() throws {
        
        let repository = FileRepositoryImpl()
        try repository.deleteTheme(name: "Theme1")
        
        let themes = try repository.getAllThemes()
        
        XCTAssertEqual(themes.count, 1)
        XCTAssertEqual(themes.joined(separator: ""), "Theme2")
    }
    
    func testCanViewThemeNotFound() throws {
        
        let repository = FileRepositoryImpl()
        
        do {
            _ = try repository.readThemeFileData(in: "Theme3", at: "/js/test.js", type: .publicResource)
            XCTFail()
        } catch let error as Abort where error.status == .notFound {
            XCTAssertTrue(true)
        }
    }
}

extension FileRepositoryTests {
    public static let allTests = [
        ("testCanGetAccessibleFilesOriginalOnlyNoTheme", testCanGetAccessibleFilesOriginalOnlyNoTheme),
        ("testCanCreateUserData", testCanCreateUserData),
        ("testCanDeleteUserData", testCanDeleteUserData),
        ("testCanViewNotFound", testCanViewNotFound),
        ("testCanGetFilesInATheme", testCanGetFilesInATheme),
        ("testCanGetAllThemes", testCanGetAllThemes),
        ("testCanSaveTheme", testCanSaveTheme),
        ("testCanCopyTheme", testCanCopyTheme),
        ("testCanDeleteTheme", testCanDeleteTheme),
        ("testCanViewThemeNotFound", testCanViewThemeNotFound)
    ]
}