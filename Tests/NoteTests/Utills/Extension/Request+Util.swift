import HTTP
import Vapor

extension Request {
    
    func setFormData(_ formDataJSON: JSON, _ csrfToken: String) throws {
        var formDataJSON = formDataJSON
        try formDataJSON.set("csrf-token", csrfToken)
        json = formDataJSON
    }
}
