@testable import App
import Vapor
import XCTest
import Foundation

final class ImageRepositoryTests: FileHandleTestCase {
    
    func testCanSaveAndDeleteImage() throws {
        
        let repository = ImageRepositoryImpl()
        
        try repository.saveImage(data: "image".data(using: .utf8)!, at: "/documents/imgs/test.png")
        XCTAssertTrue(repository.isExist(at: "/documents/imgs/test.png"))
        
        try repository.deleteImage(at: "/documents/imgs/test.png")
        XCTAssertFalse(repository.isExist(at: "/documents/imgs/test.png"))
    }
    
    func testCanRenameImage() throws {
        
        let repository = ImageRepositoryImpl()
        
        try repository.saveImage(data: "image".data(using: .utf8)!, at: "/documents/imgs/test.png")
        XCTAssertTrue(repository.isExist(at: "/documents/imgs/test.png"))
        
        try repository.renameImage(at: "/documents/imgs/test.png", to: "/documents/imgs/renamed.png")
        XCTAssertFalse(repository.isExist(at: "/documents/imgs/test.png"))
        XCTAssertTrue(repository.isExist(at: "/documents/imgs/renamed.png"))
    }
}
