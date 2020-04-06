import Cryptor
import Vapor

protocol ImageNameGenerator {
    func generateImageName(from string: String) throws -> String
}

final class DefaultImageNameGenerator: ImageNameGenerator {
    func generateImageName(from _: String) throws -> String {
        return try Random.generate(byteCount: 16).base64.replacingOccurrences(of: "/", with: "_")
    }
}

struct ImageNameGeneratorKey {}

extension ImageNameGeneratorKey: StorageKey {
    typealias Value = ImageNameGenerator
}

extension Application {
    func register(imageNameGenerator: ImageNameGenerator) {
        storage[ImageNameGeneratorKey.self] = imageNameGenerator
    }

    var imageNameGenerator: ImageNameGenerator {
        guard let imageNameGenerator = storage[ImageNameGeneratorKey.self] else {
            fatalError("service not initialized")
        }
        return imageNameGenerator
    }
}
