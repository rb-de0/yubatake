import CSRF
import FluentProvider
import LeafProvider
import MarkdownProvider
import MySQLProvider
import RedisProvider
import Sessions
import VaporSecurityHeaders

extension Config {
    public func setup() throws {
        
        Node.fuzzy = [Row.self, JSON.self, Node.self]

        try setupProviders()
        try setupConfigurable()
        try setupPreparations()
    }
    
    private func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
        try addProvider(LeafProvider.Provider.self)
        try addProvider(MarkdownProvider.Provider.self)
        try addProvider(MySQLProvider.Provider.self)
    }
    
    private func setupConfigurable() throws {
        
        // Security Headers
        let config = CSPConfig(config: self)
        let securityHeadersFactory = SecurityHeadersFactory()
        let cspConfig = ContentSecurityPolicyConfiguration(value: config.makeConfigirationString())
        securityHeadersFactory.with(contentSecurityPolicy: cspConfig)
        addConfigurable(middleware: securityHeadersFactory.builder(), name: "security-headers")
        
        // CSRF
        let csrf = CSRF { request in request.data["csrf-token"]?.string ?? "" }
        addConfigurable(middleware: csrf, name: "csrf")
        
        // Redis Session Store
        let redisCache = try RedisCache(config: self)
        let sessions = CacheSessions(redisCache, defaultExpiration: 86400)
        addConfigurable(middleware: { _ in SessionsMiddleware(sessions) }, name: "redis-sessions")
    }
    
    private func setupPreparations() throws {
        preparations = [
            Category.self,
            User.self,
            Post.self,
            Tag.self,
            SiteInfo.self,
            Pivot<Post, Tag>.self,
            PivotPostTag.self
        ]
    }
}
