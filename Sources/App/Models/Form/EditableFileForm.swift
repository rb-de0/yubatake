import Vapor

struct EditableFileForm: Content {

    private enum CodingKeys: String, CodingKey {
        case path
    }

    let path: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        path = try container.decode(String.self, forKey: .path).requireAllowedPath()
    }
}
