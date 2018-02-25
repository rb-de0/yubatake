@testable import App
import XCTest

class ModelTestCase: XCTestCase {

    private(set) var drop: Droplet!
    
    override class func setUp() {
        try! dropDB()
    }
    
    override func setUp() {
        try! createDB()
        drop = try! ConfigBuilder.defaultDrop(with: self)
    }
    
    override func tearDown() {
        try! dropDB()
    }
}

