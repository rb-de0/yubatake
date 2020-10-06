@testable import App
import XCTVapor
import XCTest
import Fluent

class ControllerTestCase: XCTestCase {
    
    private(set) var app: Application!
    private(set) var testable: XCTApplicationTester!
    private(set) var view: TestViewDecorator!
    private(set) var db: Database!
    private(set) var cookies: HTTPCookies?
    private(set) var csrfToken = ""
    
    override func setUp() {
        super.setUp()
        try! ApplicationBuilder.migrate()
        app = buildApp()
        testable = try! app.testable()
        view = app.testViewDecorator
        db = app.db
        cookies = nil
        try! test(.GET, "csrf") { response in
            self.csrfToken = try! response.content.decode(CSRFToken.self).token
        }
    }
    
    override func tearDown() {
        super.tearDown()
        app.shutdown()
        try! ApplicationBuilder.revert()
    }
    
    func buildApp() -> Application {
        return try! ApplicationBuilder.buildForAdmin()
    }
    
    func test( _ method: HTTPMethod,
               _ path: String,
               headers: HTTPHeaders = [:],
               body: String? = nil,
               withCSRFToken: Bool = true,
               beforeRequest: (inout XCTHTTPRequest) throws -> () = { _ in },
               afterResponse: (XCTHTTPResponse) throws -> () = { _ in }) throws {
        var requestHeaders = HTTPHeaders()
        requestHeaders.contentType = .urlEncodedForm
        requestHeaders.add(contentsOf: headers)
        let bodyData: ByteBuffer?
        if var body = body {
            if withCSRFToken {
                body = body + "&csrfToken=\(csrfToken)"
            }
            var bodyBuffer = ByteBufferAllocator().buffer(capacity: 0)
            bodyBuffer.writeString(body)
            bodyData = bodyBuffer
        } else {
            if withCSRFToken {
                let body = "csrfToken=\(csrfToken)"
                var bodyBuffer = ByteBufferAllocator().buffer(capacity: 0)
                bodyBuffer.writeString(body)
                bodyData = bodyBuffer
            } else {
                bodyData = nil
            }
        }
        let beforeRequestHandler: (inout XCTHTTPRequest) throws -> () = { [weak self] request in
            request.headers.cookie = self?.cookies
            try beforeRequest(&request)
        }
        let afterResponseHandler: (XCTHTTPResponse) throws -> () = { [weak self] response in
            if let setCookie = response.headers.setCookie {
                self?.cookies = setCookie
            }
            try afterResponse(response)
        }
        try testable.test(method, path, headers: requestHeaders, body: bodyData,
                          beforeRequest: beforeRequestHandler,
                          afterResponse: afterResponseHandler)
    }
}
