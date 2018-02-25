@testable import App
import Fluent
import HTTP
import XCTest

final class MigrationTests: XCTestCase {
    
    private var dataBase: Database!
    private var preparations = [Preparation.Type]()
    
    override class func setUp() {
        try! dropDB()
    }
    
    override func setUp() {
        
        try! createDB()
        
        var config = Config([:])
        try! config.set("fluent.driver", "mysql")
        try! config.setup()
        
        preparations = config.preparations
        dataBase = Database(try! DB.driver(database: type(of: self).dbName))
    }
    
    override func tearDown() {
        try! dropDB()
    }
    
    func testCanPrepareAndRevertInOrder() throws {
        
        do {
            for preparation in preparations {
                try dataBase.prepare([preparation])
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        do {
            for preparation in preparations.reversed() {
                try dataBase.revertBatch([preparation])
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}

extension MigrationTests {
    public static let allTests = [
        ("testCanPrepareAndRevertInOrder", testCanPrepareAndRevertInOrder)
    ]
}