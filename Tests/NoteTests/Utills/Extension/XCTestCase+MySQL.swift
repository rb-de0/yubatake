import XCTest

extension XCTestCase {
    
    static var dbName: String {
        return String(describing: self).lowercased()
    }
    
    class func createDB() throws {
        try DB.create(name: dbName)
    }
    
    class func dropDB() throws {
        try DB.drop(name: dbName)
    }
    
    func createDB() throws {
        try DB.create(name: type(of: self).dbName)
    }
    
    func dropDB() throws {
        try DB.drop(name: type(of: self).dbName)
    }
}
