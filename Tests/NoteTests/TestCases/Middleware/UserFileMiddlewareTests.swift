@testable import App
import Vapor
import XCTest
import Foundation

final class UserFileMiddlewareTests: FileHandleTestCase {

    func testCanGetFile() throws {
        
        let request = Request(method: .get, uri: "/js/test.js")
        let response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
    }
    
    func testCanGetUserFile() throws {
        
        // TODO: Check getting customized data
        let repository = FileRepositoryImpl()
        try repository.writeUserFileData(at: "/js/test.js", type: .publicResource, data: "JavaScriptTestCodeUpdated")
        
        let request = Request(method: .get, uri: "/js/test.js")
        let response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
    }
    
    func testCanBlockDirectoryTraversal() throws {
        
        let request = Request(method: .get, uri: "/../Package.swift")
        let response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .forbidden)
    }
}

extension UserFileMiddlewareTests {
    public static let allTests = [
        ("testCanGetFile", testCanGetFile),
        ("testCanGetUserFile", testCanGetUserFile)
    ]
}
