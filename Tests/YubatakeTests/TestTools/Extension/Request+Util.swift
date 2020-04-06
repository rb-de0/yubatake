//import Vapor
//
//extension HTTPRequest {
//    
//    func makeRequest(using container: Container) -> Request {
//        return Request(http: self, using: container)
//    }
//}
//
//extension Request {
//    
//    private struct ContentWrapper<T: Content>: Encodable {
//        
//        private enum CodingKeys: String, CodingKey {
//            case csrfToken = "csrf-token"
//        }
//        
//        let source: T
//        let csrfToken: String
//        
//        func encode(to encoder: Encoder) throws {
//            try source.encode(to: encoder)
//            var container = encoder.container(keyedBy: CodingKeys.self)
//            try container.encode(csrfToken, forKey: .csrfToken)
//        }
//    }
//    
//    func setFormData<T: Content>(_ content: T, csrfToken: String) throws {
//        try self.content.encode(ContentWrapper(source: content, csrfToken: csrfToken), as: .urlEncodedForm)
//    }
//    
//    func setJSONData<T: Content>(_ content: T, csrfToken: String) throws {
//        try self.content.encode(ContentWrapper(source: content, csrfToken: csrfToken), as: .json)
//    }
//    
//    func setMultipartData<T: Content>(_ content: T, csrfToken: String) throws {
//        try self.content.encode(ContentWrapper(source: content, csrfToken: csrfToken), as: .formData)
//    }
//}
