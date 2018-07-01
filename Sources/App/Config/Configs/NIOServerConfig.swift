import Vapor

extension NIOServerConfig: LocalConfig {
    
    static var fileName: String {
        return "server"
    }
    
    private enum CodingKeys: String, CodingKey {
        case hostname
        case port
        case backlog
        case workerCount
        case maxBodySize
        case reuseAddress
        case tcpNoDelay
    }
    
    public init(from decoder: Decoder) throws {
        
        let config = NIOServerConfig.default()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let hostname = try container.decodeIfPresent(String.self, forKey: .hostname) ?? config.hostname
        let port = try container.decodeIfPresent(Int.self, forKey: .port) ?? config.port
        let backlog = try container.decodeIfPresent(Int.self, forKey: .backlog) ?? config.backlog
        let workerCount = try container.decodeIfPresent(Int.self, forKey: .workerCount) ?? config.workerCount
        let maxBodySize = try container.decodeIfPresent(Int.self, forKey: .maxBodySize) ?? config.maxBodySize
        let reuseAddress = try container.decodeIfPresent(Bool.self, forKey: .reuseAddress) ?? config.reuseAddress
        let tcpNoDelay = try container.decodeIfPresent(Bool.self, forKey: .tcpNoDelay) ?? config.tcpNoDelay
        
        self.init(
            hostname: hostname,
            port: port,
            backlog: backlog,
            workerCount: workerCount,
            maxBodySize: maxBodySize,
            reuseAddress: reuseAddress,
            tcpNoDelay: tcpNoDelay
        )
    }
}
