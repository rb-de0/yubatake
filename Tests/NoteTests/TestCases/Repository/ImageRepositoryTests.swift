@testable import App
import Vapor
import XCTest

final class ImageRepositoryTests: XCTestCase {
    
    private static let workDir = DirectoryConfig.detect().workDir + "/.test"
    private static let config = DirectoryConfig(workDir: workDir)
    
    private var app: Application!
    private let fm = FileManager.default
    
    private var workDir: String {
        return ImageRepositoryTests.workDir
    }
    
    override func setUp() {
        
        try! ApplicationBuilder.clear()
        
        if !fm.fileExists(atPath: workDir) {
            try! fm.createDirectory(atPath: workDir, withIntermediateDirectories: true, attributes: nil)
        }
        
        app = try! ApplicationBuilder.build(forAdminTests: true) { (_config, _services) in
            var services = _services
            services.register(ImageRepositoryTests.config, as: DirectoryConfig.self)
            return (_config, services)
        }
    }
    
    override func tearDown() {
        if fm.fileExists(atPath: workDir) {
            try! fm.removeItem(atPath: workDir)
        }
    }
    
    func testCanSaveAndDeleteImage() throws {
        
        let repository = try app.make(ImageRepositoryDefault.self)
        
        try repository.save(image: "image".data(using: .utf8)!, for: "test.png")
        XCTAssertTrue(repository.isExist(at: "test.png"))
        
        try repository.delete(at: "test.png")
        XCTAssertFalse(repository.isExist(at: "test.png"))
    }
    
    func testCanRenameImage() throws {
        
        let repository = try app.make(ImageRepositoryDefault.self)
        
        try repository.save(image: "image".data(using: .utf8)!, for: "test.png")
        XCTAssertTrue(repository.isExist(at: "test.png"))
        
        try repository.rename(from: "test.png", to: "renamed.png")
        XCTAssertTrue(repository.isExist(at: "renamed.png"))
        XCTAssertFalse(repository.isExist(at: "test.png"))
    }
}

extension ImageRepositoryTests {
    public static let allTests = [
        ("testCanSaveAndDeleteImage", testCanSaveAndDeleteImage),
        ("testCanRenameImage", testCanRenameImage)
    ]
}
