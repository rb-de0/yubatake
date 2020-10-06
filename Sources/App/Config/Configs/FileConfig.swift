import Vapor

struct FileConfig: Decodable {

    let themeRoot = "themes"
    let imageRoot = "documents/imgs"
    let workingDirectory: String
    let publicDirecoty: String
    let themeDirectory: String
    let imageDirectory: String

    init(directory: DirectoryConfiguration) {
        workingDirectory = directory.workingDirectory
        publicDirecoty = directory.publicDirectory
        themeDirectory = directory.publicDirectory.finished(with: "/").appending(themeRoot)
        imageDirectory = directory.publicDirectory.finished(with: "/").appending(imageRoot)
    }

    func templateDirectory(in theme: String) -> String {
        return themeDirectory.finished(with: "/")
            .appending(theme).finished(with: "/")
            .appending("template").finished(with: "/")
    }
}

extension FileConfig: StorageKey {
    typealias Value = FileConfig
}

extension Application {
    func register(fileConfig: FileConfig) {
        storage[FileConfig.self] = fileConfig
    }

    var fileConfig: FileConfig {
        guard let fileConfig = storage[FileConfig.self] else {
            fatalError("service not initialized")
        }
        return fileConfig
    }
}
