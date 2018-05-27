import Vapor

struct ApplicationConfig: LocalConfig, Service {
    
    static var fileName: String {
        return "app"
    }
    
    let tweetFormat: String?
    let hostName: String
    let dateFormat: String
    let imageGroupDateFormat: String
    let faviconPath: String?
    let meta: Meta?
    
    struct Meta: Content {

        private enum EncodingKeys: String, CodingKey {
            case pageDescription = "page_description"
            case pageImage = "page_image"
            case twitter
        }
        
        let pageDescription: String
        let pageImage: String
        let twitter: TwitterMeta?
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: EncodingKeys.self)
            try container.encode(pageDescription, forKey: .pageDescription)
            try container.encode(pageImage, forKey: .pageImage)
            try container.encodeIfPresent(twitter, forKey: .twitter)
        }
    }
    
    struct TwitterMeta: Content {

        private enum EncodingKeys: String, CodingKey {
            case imageAlt = "image_alt"
            case username
        }
        
        let imageAlt: String
        let username: String
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: EncodingKeys.self)
            try container.encode(imageAlt, forKey: .imageAlt)
            try container.encode(username, forKey: .username)
        }
    }
}
