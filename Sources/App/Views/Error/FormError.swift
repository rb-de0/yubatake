import Vapor

private struct FormErrorConst {
    static let formDataKey = "form_data"
}

struct FormError<T: Codable> {
    let error: Error
    let formData: T

    func makeJSON() throws -> String? {
        let jsonData = try JSONEncoder().encode(formData)
        return String(data: jsonData, encoding: .utf8)
    }
}

extension Request {
    func redirect<T: Encodable>(to location: String, with formError: FormError<T>) throws -> Response {
        session.data[FormErrorConst.formDataKey] = try formError.makeJSON()
        return try redirect(to: location, with: formError.error.localizedDescription)
    }
}

extension Form {
    static func restoreFormData(from request: Request) throws -> Self? {
        guard let formData = request.session.data[FormErrorConst.formDataKey],
            let data = formData.data(using: .utf8) else {
            return nil
        }
        request.session.data[FormErrorConst.formDataKey] = nil
        return try JSONDecoder().decode(self, from: data)
    }
}
