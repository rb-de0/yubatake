//@testable import App
//import CSRF
//import Crypto
//import FluentMySQL
//import Vapor
//import XCTest
//
//protocol AdminTestCase {}
//
//class ControllerTestCase: XCTestCase {
//    
//    private(set) var app: Application!
//    private(set) var view: TestViewDecorator!
//    private(set) var conn: MySQLConnection!
//    private(set) var csrfToken: String!
//    
//    private var responder: Responder!
//    private var cookies: HTTPCookies?
//    
//    // MARK: - Life Cycle
//
//    override func setUp() {
//        try! ApplicationBuilder.clear()
//        
//        app = try! buildApp()
//        view = try! app.make(TestViewDecorator.self)
//        responder = try! app.make(Responder.self)
//        conn = try! app.newConnection(to: .mysql).wait()
//        csrfToken = try! prepareSession()
//    }
//    
//    override func tearDown() {
//        try! app.make(BlockingIOThreadPool.self).syncShutdownGracefully()
//        conn.close()
//    }
//    
//    // MARK: - Build App
//    
//    func buildApp() throws -> Application {
//        return try ApplicationBuilder.build(forAdminTests: self is AdminTestCase)
//    }
//
//    // MARK: - Utility
//    
//    func waitResponse(method: HTTPMethod, url: String, build: ((Request) throws -> ())? = nil) throws -> Response {
//        
//        let request = HTTPRequest(method: method, url: url).makeRequest(using: app)
//        try build?(request)
//        
//        if let _cookies = cookies {
//            request.http.cookies = _cookies
//        }
//        
//        let response = try responder.respond(to: request).wait()
//        cookies = response.http.cookies
//
//        return response
//    }
//
//    // MARK: - Private
//    
//    private func prepareSession() throws -> String {
//        
//        let request = HTTPRequest(method: .GET, url: "/login").makeRequest(using: app)
//        let response = try responder.respond(to: request).wait()
//        cookies = response.http.cookies
//        
//        return try CSRF().createToken(from: request)
//    }
//}
