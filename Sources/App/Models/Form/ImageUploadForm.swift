import Vapor

struct ImageUploadForm: Form, Content {

    private enum CodingKeys: String, CodingKey {
        case data = "imageFileData"
        case name = "imageFileName"
    }

    let data: Data
    let name: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode(Data.self, forKey: .data)
        name = try container.decode(String.self, forKey: .name).requireAllowedPath()
    }
}
