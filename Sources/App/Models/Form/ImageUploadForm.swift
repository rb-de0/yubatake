import Vapor

struct ImageUploadForm: Form, Content {
    
    private enum CodingKeys: String, CodingKey {
        case data = "image_file_data"
        case name = "image_file_name"
    }
    
    let data: Data
    let name: String
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode(Data.self, forKey: .data)
        name = try container.decode(String.self, forKey: .name)
        
        try name.requireAllowedPath()
    }
}
