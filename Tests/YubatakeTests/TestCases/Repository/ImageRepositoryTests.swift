@testable import App
import XCTVapor

final class ImageRepositoryTests: XCTestCase {
    
    private let fm = FileManager.default
    private static let workDirectory = String.workingDirectory.appending("/.test")
    private static let fileConfig = FileConfig(directory: DirectoryConfiguration(workingDirectory: workDirectory))

    override func setUp() {
        super.setUp()
        if !fm.fileExists(atPath: Self.workDirectory) {
            try! fm.createDirectory(atPath: Self.workDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    override func tearDown() {
        super.tearDown()
        if fm.fileExists(atPath: Self.workDirectory) {
            try! fm.removeItem(atPath: Self.workDirectory)
        }
    }
    
    func testCanSaveAndDeleteImage() throws {
        let repository = DefaultImageRepository(fileConfig: Self.fileConfig)
        try repository.save(image: "image".data(using: .utf8)!, for: "test.png")
        XCTAssertTrue(repository.isExist(at: "test.png"))
        try repository.delete(at: "test.png")
        XCTAssertFalse(repository.isExist(at: "test.png"))
    }
    
    func testCanRenameImage() throws {
        let repository = DefaultImageRepository(fileConfig: Self.fileConfig)
        try repository.save(image: "image".data(using: .utf8)!, for: "test.png")
        XCTAssertTrue(repository.isExist(at: "test.png"))
        try repository.rename(from: "test.png", to: "renamed.png")
        XCTAssertTrue(repository.isExist(at: "renamed.png"))
        XCTAssertFalse(repository.isExist(at: "test.png"))
    }
}
