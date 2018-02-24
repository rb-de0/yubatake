import HTTP
import Vapor

extension Request {
    
    func setFormData(_ formDataJSON: JSON, _ csrfToken: String) throws {
        var formDataJSON = formDataJSON
        try formDataJSON.set("csrf-token", csrfToken)
        formURLEncoded = formDataJSON.makeNode(in: nil)
    }
    
    func setJSONData(_ jsonData: JSON, _ csrfToken: String) throws {
        var jsonData = jsonData
        try jsonData.set("csrf-token", csrfToken)
        json = jsonData
    }
}
