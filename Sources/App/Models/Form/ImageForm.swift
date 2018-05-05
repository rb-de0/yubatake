import Vapor

struct ImageForm: Form, Content {
    
    private enum CodingKeys: String, CodingKey {
        case name
        case altDescription = "alt_description"
    }
    
    let name: String
    let altDescription: String
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        altDescription = try container.decode(String.self, forKey: .altDescription)
        
        try name.requireAllowedPath()
    }
}
