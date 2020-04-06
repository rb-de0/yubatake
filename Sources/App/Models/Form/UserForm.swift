import Vapor

struct UserForm: Form, Content {

    private enum CodingKeys: String, CodingKey {
        case name
        case password
        case apiKey
        case apiSecret
        case accessToken
        case accessTokenSecret
    }

    let name: String
    let password: String
    let apiKey: String?
    let apiSecret: String?
    let accessToken: String?
    let accessTokenSecret: String?
}

extension UserForm: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: .count(1 ... User.nameLength))
    }
}

extension UserForm {
    struct RenderingContext: Encodable {
        private enum CodingKeys: String, CodingKey {
            case name
            case apiKey
            case apiSecret
            case accessToken
            case accessTokenSecret
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

    func makeRenderingContext() throws -> Encodable {
        return RenderingContext(form: self)
    }
}
