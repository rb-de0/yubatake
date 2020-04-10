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
    
    override func setUp() {
        super.setUp()
        try! ApplicationBuilder.migrate()
        app = buildApp()
        testable = try! app.testable()
        view = app.testViewDecorator
        db = app.db
        cookies = nil
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
                   beforeRequest: (inout XCTHTTPRequest) throws -> () = { _ in },
                   afterResponse: (XCTHTTPResponse) throws -> () = { _ in }) throws {
        var requestHeaders = HTTPHeaders()
        requestHeaders.contentType = .urlEncodedForm
        requestHeaders.add(contentsOf: headers)
        let bodyData: ByteBuffer?
        if let body = body {
            var bodyBuffer = ByteBufferAllocator().buffer(capacity: 0)
            bodyBuffer.writeString(body)
            bodyData = bodyBuffer
        } else {
            bodyData = nil
        }
        let beforeRequestHandler: (inout XCTHTTPRequest) throws -> () = { [weak self] request in
            request.headers.cookie = self?.cookies
            try beforeRequest(&request)
        }
        let afterResponseHandler: (XCTHTTPResponse) throws -> () = { [weak self] response in
            self?.cookies = response.headers.setCookie
            try afterResponse(response)
        }
        try testable.test(method, path, headers: requestHeaders, body: bodyData,
                          beforeRequest: beforeRequestHandler,
                          afterResponse: afterResponseHandler)
    }
}
