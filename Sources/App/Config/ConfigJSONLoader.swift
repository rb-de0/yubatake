import Vapor

final class ConfigJSONLoader {
    class func load<T: Decodable>(fo app: Application, name: String) throws -> T {
        let configDirectory = app.directory.workingDirectory.finished(with: "/").appending("Config")
        let targetDirectories = ["", "secrets", app.environment.name]
        var configFileData: Data?
        for target in targetDirectories {
            let configFilePath = configDirectory.finished(with: "/")
                .appending(target).finished(with: "/")
                .appending(name)
                .appending(".json")
            guard let data = FileManager.default.contents(atPath: configFilePath) else {
                continue
            }
            configFileData = data
        }
        guard let data = configFileData else {
            fatalError("config file not found")
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
