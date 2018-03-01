@testable import App
import Vapor
import XCTest
import Foundation

final class FileRepositoryTests: FileHandleTestCase {
    
    func testCanSaveAndDeleteImage() throws {
        
        let repository = FileRepositoryImpl()
        
        try repository.saveImage(data: "image".data(using: .utf8)!, at: "/documents/imgs/test.png")
        XCTAssertTrue(repository.isExistPublicResource(path: "/documents/imgs/test.png"))
        
        try repository.deleteImage(at: "/documents/imgs/test.png")
        XCTAssertFalse(repository.isExistPublicResource(path: "/documents/imgs/test.png"))
    }
    
    func testCanRenameImage() throws {
        
        let repository = FileRepositoryImpl()
        
        try repository.saveImage(data: "image".data(using: .utf8)!, at: "/documents/imgs/test.png")
        XCTAssertTrue(repository.isExistPublicResource(path: "/documents/imgs/test.png"))
        
        try repository.renameImage(at: "/documents/imgs/test.png", to: "/documents/imgs/renamed.png")
        XCTAssertFalse(repository.isExistPublicResource(path: "/documents/imgs/test.png"))
        XCTAssertTrue(repository.isExistPublicResource(path: "/documents/imgs/renamed.png"))
    }
    
    func testCanGetAccessibleFilesOriginalOnly() throws {
        
        let repository = FileRepositoryImpl()
        let groups = repository.accessibleFiles()
        
        XCTAssertEqual(groups.count, 3)
        
        for group in groups {
            group.files.forEach {
                XCTAssertNil($0.userPathToRoot)
            }
            XCTAssertEqual(group.files.count, 1)
        }
    }
    
    func testCanCreateUserData() throws {
        
        var updated = ""
        var groups = [AccessibleFileGroup]()
        
        let repository = FileRepositoryImpl()
        try repository.writeUserFileData(at: "/js/test.js", type: .publicResource, data: "JavaScriptTestCodeUpdated")
        updated = try repository.readFileData(at: "/user/js/test.js", type: .publicResource)
        
        XCTAssertEqual(updated, "JavaScriptTestCodeUpdated")
        
        groups = repository.accessibleFiles()
        XCTAssertNotNil(groups.flatMap { $0.files }.first (where: { $0.relativePath == "/js/test.js" })?.userPathToRoot)
        
        try repository.writeUserFileData(at: "/styles/test.css", type: .publicResource, data: "CSSTestStyleUpdated")
        updated = try repository.readFileData(at: "/user/styles/test.css", type: .publicResource)
        
        XCTAssertEqual(updated, "CSSTestStyleUpdated")
        
        groups = repository.accessibleFiles()
        XCTAssertNotNil(groups.flatMap { $0.files }.first (where: { $0.relativePath == "/styles/test.css" })?.userPathToRoot)
        
        try repository.writeUserFileData(at: "/test/test.leaf", type: .view, data: "LeafTestTemplateUpdated")
        updated = try repository.readFileData(at: "/user/test/test.leaf", type: .view)
        
        XCTAssertEqual(updated, "LeafTestTemplateUpdated")
        
        groups = repository.accessibleFiles()
        XCTAssertNotNil(groups.flatMap { $0.files }.first (where: { $0.relativePath == "/test/test.leaf" })?.userPathToRoot)
    }
    
    func testCanDeleteUserData() throws {
        
        var groups = [AccessibleFileGroup]()
        
        let repository = FileRepositoryImpl()
        try repository.writeUserFileData(at: "/js/test.js", type: .publicResource, data: "JavaScriptTestCodeUpdated")
        try repository.deleteUserFileData(at: "/js/test.js", type: .publicResource)
        
        groups = repository.accessibleFiles()
        XCTAssertNil(groups.flatMap { $0.files }.first (where: { $0.relativePath == "/js/test.js" })?.userPathToRoot)
        
        try repository.writeUserFileData(at: "/styles/test.css", type: .publicResource, data: "CSSTestStyleUpdated")
        try repository.deleteUserFileData(at: "/styles/test.css", type: .publicResource)
        
        groups = repository.accessibleFiles()
        XCTAssertNil(groups.flatMap { $0.files }.first (where: { $0.relativePath == "/styles/test.css" })?.userPathToRoot)
        
        try repository.writeUserFileData(at: "/test/test.leaf", type: .view, data: "LeafTestTemplateUpdated")
        try repository.deleteUserFileData(at: "/test/test.leaf", type: .view)
        
        groups = repository.accessibleFiles()
        XCTAssertNil(groups.flatMap { $0.files }.first (where: { $0.relativePath == "/test/test.leaf" })?.userPathToRoot)
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

extension FileRepositoryTests {
    public static let allTests = [
        ("testCanSaveAndDeleteImage", testCanSaveAndDeleteImage),
        ("testCanRenameImage", testCanRenameImage),
        ("testCanGetAccessibleFilesOriginalOnly", testCanGetAccessibleFilesOriginalOnly),
        ("testCanCreateUserData", testCanCreateUserData),
        ("testCanDeleteUserData", testCanDeleteUserData),
        ("testCanViewNotFound", testCanViewNotFound)
    ]
}
