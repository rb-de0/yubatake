import Vapor

struct UserForm: Form, Content {
    
    private enum CodingKeys: String, CodingKey {
        case name
        case password
        case apiKey = "api_key"
        case apiSecret = "api_secret"
        case accessToken = "access_token"
        case accessTokenSecret = "access_token_secret"
    }
    
    struct RenderingContext: Encodable {
        
        private enum CodingKeys: String, CodingKey {
            case name
            case apiKey = "api_key"
            case apiSecret = "api_secret"
            case accessToken = "access_token"
            case accessTokenSecret = "access_token_secret"
        }

        let form: UserForm
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(form.name, forKey: .name)
            try container.encode(form.apiKey, forKey: .apiKey)
            try container.encode(form.apiSecret, forKey: .apiSecret)
            try container.encode(form.accessToken, forKey: .accessToken)
            try container.encode(form.accessTokenSecret, forKey: .accessTokenSecret)
        }
    }
    
    let name: String
    let password: String
    let apiKey: String?
    let apiSecret: String?
    let accessToken: String?
    let accessTokenSecret: String?
    
    func makeRenderingContext() throws -> Encodable {
        return RenderingContext(form: self)
    }
}
