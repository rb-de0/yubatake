import FluentMySQL
import Vapor

extension MySQLDatabaseConfig: LocalConfig {
    
    static var fileName: String {
        return "mysql"
    }
    
    private enum CodingKeys: String, CodingKey {
        case hostname
        case port
        case username
        case password
        case database
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let hostname = try container.decode(String.self, forKey: .hostname)
        let port = try container.decodeIfPresent(Int.self, forKey: .port) ?? 3306
        let username = try container.decode(String.self, forKey: .username)
        let password = try container.decodeIfPresent(String.self, forKey: .password)
        let database = try container.decode(String.self, forKey: .database)
        self.init(hostname: hostname, port: port, username: username, password: password, database: database)
    }
}
