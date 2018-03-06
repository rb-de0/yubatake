@testable import App
import Vapor
import XCTest
import Foundation

class FileHandleTestCase: XCTestCase {
    
    private(set) var drop: Droplet!
    
    var tmpDir: String {
        return "." + type(of: self).dbName
    }
    
    var testDir: String {
        return drop.config.workDir.finished(with: "/")
    }
    
    var cssDir: String {
        return testDir + "/Public/styles"
    }
    
    var jsDir: String {
        return testDir + "/Public/js"
    }
    
    var viewsDir: String {
        return testDir + "/Resources/Views"
    }
    
    var themeDir: String {
        return testDir + "theme"
    }
    
    var testViewsDir: String {
        return viewsDir + "/test"
    }
    
    var fm: FileManager {
        return FileManager.default
    }
    
    override class func setUp() {
        try! dropDB()
    }
    
    override func setUp() {
        try! createDB()
        
        let dir = Config.workingDirectory().finished(with: "/") + tmpDir
        
        drop = try! ConfigBuilder.defaultDrop(with: self) { (c: Config) in
            var config = c
            try! config.set("droplet.workDir", dir)
        }
        
        if fm.fileExists(atPath: testDir) {
            try! fm.removeItem(atPath: testDir)
        }
        try! fm.createDirectory(atPath: testDir, withIntermediateDirectories: true, attributes: nil)
        try! fm.createDirectory(atPath: jsDir, withIntermediateDirectories: true, attributes: nil)
        try! fm.createDirectory(atPath: cssDir, withIntermediateDirectories: true, attributes: nil)
        try! fm.createDirectory(atPath: testViewsDir, withIntermediateDirectories: true, attributes: nil)
        try! fm.createDirectory(atPath: themeDir, withIntermediateDirectories: true, attributes: nil)
        
        try! fm.createDirectory(atPath: themeDir.finished(with: "/") + "Theme1/Public/js", withIntermediateDirectories: true, attributes: nil)
        try! fm.createDirectory(atPath: themeDir.finished(with: "/") + "Theme1/Public/styles", withIntermediateDirectories: true, attributes: nil)
        try! fm.createDirectory(atPath: themeDir.finished(with: "/") + "Theme1/Views", withIntermediateDirectories: true, attributes: nil)
        try! fm.createDirectory(atPath: themeDir.finished(with: "/") + "Theme2", withIntermediateDirectories: true, attributes: nil)
        
        fm.createFile(atPath: jsDir + "/test.js", contents: "JavaScriptTestCode".data(using: .utf8), attributes: nil)
        fm.createFile(atPath: cssDir + "/test.css", contents: "CSSTestStyle".data(using: .utf8), attributes: nil)
        fm.createFile(atPath: testViewsDir + "/test.leaf", contents: "LeafTestTemplate".data(using: .utf8), attributes: nil)
        
        fm.createFile(atPath: themeDir.finished(with: "/") + "Theme1/Public/js/test.js", contents: "JavaScriptTestCodeForTheme1".data(using: .utf8), attributes: nil)
        fm.createFile(atPath: themeDir.finished(with: "/") + "Theme1/Views/test.leaf", contents: "LeafTestTemplateForTheme1".data(using: .utf8), attributes: nil)
    }
    
    override func tearDown() {
        try! dropDB()

        if fm.fileExists(atPath: testDir) {
            try! fm.removeItem(atPath: testDir)
        }
    }
}
