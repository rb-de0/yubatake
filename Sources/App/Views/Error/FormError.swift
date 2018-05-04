import Vapor

fileprivate struct FormErrorConst {
    static let formDataKey = "form_data"
}

struct FormError<T: Codable> {
    
    let error: Error
    let formData: T
    
    init(error: Error, formData: T) {
        self.error = error
        self.formData = formData
    }
    
    func makeJSON() throws -> String? {
        let jsonData = try JSONEncoder().encode(formData)
        return String.convertFromData(jsonData)
    }
}

extension Request {
    
    func redirect<T: Encodable>(to location: String, with formError: FormError<T>) throws -> Response {
        try session()[FormErrorConst.formDataKey] = try formError.makeJSON()
        return try redirect(to: location, with: formError.error.localizedDescription)
    }
}

extension Form {
    
    static func restoreFormData(from request: Request) throws -> Self? {
        
        guard let formData = try request.session()[FormErrorConst.formDataKey] else {
            return nil
        }
        
        try request.session()[FormErrorConst.formDataKey] = nil
        
        return try JSONDecoder().decode(self, from: formData)
    }
}

