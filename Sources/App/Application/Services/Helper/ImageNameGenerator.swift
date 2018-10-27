import Foundation
import Random
import Vapor

protocol ImageNameGenerator {
    func generateImageName(from string: String) throws -> String
}

final class ImageNameGeneratorDefault: ImageNameGenerator, Service {
    
    private let generator: DataGenerator
    
    init(generator: DataGenerator) {
        self.generator = generator
    }
    
    func generateImageName(from string: String) throws -> String {
        return try generator.generateData(count: 16).base64URLEncodedString()
    }
}
