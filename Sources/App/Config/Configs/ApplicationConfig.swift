import Vapor

struct ApplicationConfig: Decodable {
    let tweetFormat: String?
    let hostName: String
    let dateFormat: String
    let imageGroupDateFormat: String
    let faviconPath: String?
    let meta: Meta?
    let useRedis: Bool?
}

extension ApplicationConfig {
    struct Meta: Content {
        private enum EncodingKeys: String, CodingKey {
            case pageDescription
            case pageImage
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
            case imageAlt
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

extension ApplicationConfig: StorageKey {
    typealias Value = ApplicationConfig
}

extension Application {
    func register(applicationConfig: ApplicationConfig) {
        storage[ApplicationConfig.self] = applicationConfig
    }

    var applicationConfig: ApplicationConfig {
        guard let applicationConfig = storage[ApplicationConfig.self] else {
            fatalError("service not initialized")
        }
        return applicationConfig
    }
}
