import Redis

extension RedisClientConfig: LocalConfig {
    
    static var fileName: String {
        return "redis"
    }
}
