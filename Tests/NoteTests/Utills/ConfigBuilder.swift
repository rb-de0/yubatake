@testable import App
import Vapor
import XCTest

final class ConfigBuilder {
    
    class func defaultDrop<T: XCTestCase>(with testCase: T) throws -> Droplet {
        
        var config = Config([:])
        config.addConfigurable(view: { _ in TestViewRenderer() }, name: "test")
        
        try! config.set("droplet.middleware", ["error", "date", "file", "sessions", "security-headers", "csrf", "message"])
        try! config.set("droplet.view", "test")
        try! config.set("fluent.driver", "mysql")
        try! config.set("mysql.user", "root")
        try! config.set("mysql.password", "root")
        try! config.set("mysql.hostname", "127.0.0.1")
        try! config.set("mysql.database", type(of: testCase).dbName)
        try! config.set("mysql.port", 3307)
        try! config.setup()
        
        let drop = try! Droplet(config)
        try! drop.setup()
        
        return drop
    }
}
