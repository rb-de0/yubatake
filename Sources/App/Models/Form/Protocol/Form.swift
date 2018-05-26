import Vapor

protocol Form: Codable {
    func makeRenderingContext() throws -> Encodable
}

extension Form {
    func makeRenderingContext() throws -> Encodable {
        return self
    }
}

struct EmptyForm: Form {}
