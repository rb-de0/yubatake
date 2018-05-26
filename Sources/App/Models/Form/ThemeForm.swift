import Vapor

struct ThemeForm: Content {
    
    private enum CodingKeys: String, CodingKey {
        case name
    }
    
    let name: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name).requireAllowedPath()
    }
}
