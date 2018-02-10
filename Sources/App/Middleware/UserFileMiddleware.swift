//The MIT License (MIT)
//
//Copyright (c) 2016 Tanner Nelson
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

import HTTP
import Vapor

final class UserFileMiddleware: Middleware {
    
    private let publicDir: String
    private let userPublicDir: String
    private let chunkSize = 32_768
    
    public init(publicDir: String, userPublicDir: String) {
        self.publicDir = publicDir.finished(with: "/")
        self.userPublicDir = userPublicDir.finished(with: "/")
    }
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        do {
            return try next.respond(to: request)
        } catch RouterError.missingRoute {
            var path = request.uri.path
            guard !path.contains("../") else { throw HTTP.Status.forbidden }
            if path.hasPrefix("/") {
                path = String(path.dropFirst())
            }
            
            let filePath = publicDir + path
            let userFilePath = userPublicDir + path
            
            let ifNoneMatch = request.headers["If-None-Match"]
            
            do {
                let response = try Response(filePath: userFilePath, ifNoneMatch: ifNoneMatch, chunkSize: chunkSize)
                return response
            } catch {
                return try Response(filePath: filePath, ifNoneMatch: ifNoneMatch, chunkSize: chunkSize)
            }
        }
    }
}

