@testable import App
import Cookies
import HTTP
import Vapor
import XCTest
import Foundation

final class FileRepositoryTests: XCTestCase {
    
    private(set) var drop: Droplet!
    
    private var testDir: String {
        return drop.config.workDir.finished(with: "/") + ".test"
    }
    
    private var cssDir: String {
        return testDir + "/Public/styles"
    }
    
    private var jsDir: String {
        return testDir + "/Public/js"
    }
    
    private var viewsDir: String {
        return testDir + "/Resources/Views"
    }
    
    private var testViewsDir: String {
        return viewsDir + "/test"
    }
    
    private var fm: FileManager {
        return FileManager.default
    }
    
    override class func setUp() {
        try! dropDB()
    }
    
    override func setUp() {
        try! createDB()
        
        drop = try! ConfigBuilder.defaultDrop(with: self) { (c: Config) in
            var config = c
            try! config.set("droplet.resourcesDir", ".test/Resources")
            try! config.set("droplet.publicDir", ".test/Public")
        }

        if fm.fileExists(atPath: testDir) {
            try! fm.removeItem(atPath: testDir)
        }
        try! fm.createDirectory(atPath: testDir, withIntermediateDirectories: true, attributes: nil)
        try! fm.createDirectory(atPath: jsDir, withIntermediateDirectories: true, attributes: nil)
        try! fm.createDirectory(atPath: cssDir, withIntermediateDirectories: true, attributes: nil)
        try! fm.createDirectory(atPath: testViewsDir, withIntermediateDirectories: true, attributes: nil)
        
        fm.createFile(atPath: jsDir + "/test.js", contents: "JavaScriptTestCode".data(using: .utf8), attributes: nil)
        fm.createFile(atPath: cssDir + "/test.css", contents: "CSSTestStyle".data(using: .utf8), attributes: nil)
        fm.createFile(atPath: testViewsDir + "/test.leaf", contents: "LeafTestTemplate".data(using: .utf8), attributes: nil)
    }
    
    override func tearDown() {
        try! dropDB()
        
        if fm.fileExists(atPath: testDir) {
            try! fm.removeItem(atPath: testDir)
        }
    }
    
    func testCanSaveAndDeleteImage() throws {
        
        let repository = FileRepositoryImpl()
        
        try repository.saveImage(data: "image".data(using: .utf8)!, at: "/documents/imgs/test.png")
        XCTAssertTrue(repository.isExist(path: "/documents/imgs/test.png"))
        
        try repository.deleteImage(at: "/documents/imgs/test.png")
        XCTAssertFalse(repository.isExist(path: "/documents/imgs/test.png"))
    }
    
    func testCanRenameImage() throws {
        
        let repository = FileRepositoryImpl()
        
        try repository.saveImage(data: "image".data(using: .utf8)!, at: "/documents/imgs/test.png")
        XCTAssertTrue(repository.isExist(path: "/documents/imgs/test.png"))
        
        try repository.renameImage(at: "/documents/imgs/test.png", to: "/documents/imgs/renamed.png")
        XCTAssertFalse(repository.isExist(path: "/documents/imgs/test.png"))
        XCTAssertTrue(repository.isExist(path: "/documents/imgs/renamed.png"))
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