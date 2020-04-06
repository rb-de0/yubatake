import Vapor

struct MySQLDatabaseConfig: Decodable {
    let hostname: String
    let port: Int
    let username: String
    let password: String
    let database: String

    private enum CodingKeys: String, CodingKey {
        case hostname
        case port
        case username
        case password
        case database
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hostname = try container.decode(String.self, forKey: .hostname)
        port = try container.decodeIfPresent(Int.self, forKey: .port) ?? 3306
        username = try container.decode(String.self, forKey: .username)
        password = try container.decode(String.self, forKey: .password)
        database = try container.decode(String.self, forKey: .database)
    }
}

extension MySQLDatabaseConfig: StorageKey {
    typealias Value = MySQLDatabaseConfig
}

extension Application {
    func register(mysqlDatabaseConfig: MySQLDatabaseConfig) {
        storage[MySQLDatabaseConfig.self] = mysqlDatabaseConfig
    }

    var mysqlDatabaseConfig: MySQLDatabaseConfig {
        guard let mysqlDatabaseConfig = storage[MySQLDatabaseConfig.self] else {
            fatalError("service not initialized")
        }
        return mysqlDatabaseConfig
    }
}
