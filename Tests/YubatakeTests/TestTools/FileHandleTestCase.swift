@testable import App
import Vapor
import XCTest

class FileHandleTestCase: ControllerTestCase {
    
    private(set) var fileConfig: FileConfig!
    
    override func buildApp() throws -> Application {
        return try ApplicationBuilder.build(forAdminTests: true) { (_config, _services) in
            var services = _services
            let workDir = DirectoryConfig.detect().workDir.finished(with: "/").appending(".test")
            services.register(FileConfig(directoryConfig: DirectoryConfig(workDir: workDir)))
            return (_config, services)
        }
    }
    
    override func setUp() {
        super.setUp()
        fileConfig = try! app.make(FileConfig.self)
        try! FileManager.default.createDirectory(atPath: fileConfig.workDir, withIntermediateDirectories: false, attributes: nil)
    }
    
    override func tearDown() {
        super.tearDown()
        try! FileManager.default.removeItem(atPath: fileConfig.workDir)
    }
}
