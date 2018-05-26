import Vapor

struct EditableFileUpdateForm: Content {
    
    private enum CodingKeys: String, CodingKey {
        case path
        case body
    }
    
    let path: String
    let body: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        path = try container.decode(String.self, forKey: .path).requireAllowedPath()
        body = try container.decode(String.self, forKey: .body)
    }
}
