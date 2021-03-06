import Foundation
import Vapor

protocol ImageRepository {

    func isExist(at name: String) -> Bool

    func save(image: Data, for name: String) throws
    func delete(at name: String) throws
    func rename(from name: String, to afterName: String) throws
}

final class DefaultImageRepository: ImageRepository {

    private let directory: String

    init(fileConfig: FileConfig) {
        directory = fileConfig.imageDirectory
        do {
            try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func isExist(at name: String) -> Bool {
        return FileManager.default.fileExists(atPath: imagePath(for: name))
    }

    func save(image: Data, for name: String) throws {
        let result = FileManager.default.createFile(atPath: imagePath(for: name), contents: image, attributes: nil)
        guard result else {
            throw IOError.sameNameAlreadyExist
        }
    }

    func delete(at name: String) throws {
        try FileManager.default.removeItem(atPath: imagePath(for: name))
    }

    func rename(from name: String, to afterName: String) throws {
        try FileManager.default.moveItem(atPath: imagePath(for: name), toPath: imagePath(for: afterName))
    }

    private func imagePath(for name: String) -> String {
        return directory.finished(with: "/").appending(name)
    }
}

struct ImageRepositoryKey {}

extension ImageRepositoryKey: StorageKey {
    typealias Value = ImageRepository
}

extension Application {
    func register(imageRepository: ImageRepository) {
        storage[ImageRepositoryKey.self] = imageRepository
    }

    var imageRepository: ImageRepository {
        guard let imageRepository = storage[ImageRepositoryKey.self] else {
            fatalError("service not initialized")
        }
        return imageRepository
    }
}
