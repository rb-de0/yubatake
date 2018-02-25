@testable import App
import CSRF
import Cookies
import HTTP
import Vapor
import XCTest

class ControllerTestCase: XCTestCase {
    
    private(set) var drop: Droplet!
    private(set) var view: TestViewRenderer!
    
    typealias RequestData = (cookie: Cookie, csrfToken: String)
    
    override class func setUp() {
        try! dropDB()
    }
    
    override func setUp() {
        try! createDB()
        drop = try! ConfigBuilder.defaultDrop(with: self)
        view = drop.view as! TestViewRenderer
    }
    
    override func tearDown() {
        try! dropDB()
    }
    
    func getCSRFToken(_ path: String) throws -> RequestData {
        
        let request = Request(method: .get, uri: path)
        let response = try drop.respond(to: request)
        
        let rawCookie = response.headers[HeaderKey.setCookie]
        let sessionCookie = try Cookie(bytes: rawCookie?.bytes ?? [])
        
        let token = try CSRF().createToken(from: request)
        return (sessionCookie, token)
    }
    
    func login() throws -> RequestData {
        
        let hashedPassword = try resolve(HashProtocol.self).make("passwd").makeString()
        let user = User(name: "login", password: hashedPassword)
        try user.save()
        
        let requestData = try getCSRFToken("/login")
        
        let json: JSON = ["name": "login", "password": "passwd"]
        let request = Request(method: .post, uri: "/login")
        request.cookies.insert(requestData.cookie)
        try request.setFormData(json, requestData.csrfToken)
        let response = try drop.respond(to: request)
        
        let rawCookie = response.headers[HeaderKey.setCookie]
        let sessionCookie = try Cookie(bytes: rawCookie?.bytes ?? [])
        
        return (sessionCookie, requestData.csrfToken)
    }
}
