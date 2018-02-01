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

        setupApplicationConfig()
        
        try setupProviders()
        try setupConfigurable()
        try setupPreparations()
    }
    
    private func setupApplicationConfig() {
        ConfigProvider.app = ApplicationConfig(config: self)
        ConfigProvider.csp = CSPConfig(config: self)
    }
    
    private func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
        try addProvider(MySQLProvider.Provider.self)
    }
    
    private func setupConfigurable() throws {
        
        // Security Headers
        let securityHeadersFactory = SecurityHeadersFactory()
        let cspConfig = ContentSecurityPolicyConfiguration(value: ConfigProvider.csp.makeConfigirationString())
        securityHeadersFactory.with(contentSecurityPolicy: cspConfig)
        addConfigurable(middleware: securityHeadersFactory.builder(), name: "security-headers")
        
        // CSRF
        let csrf = CSRF { request in request.data["csrf-token"]?.string ?? "" }
        addConfigurable(middleware: csrf, name: "csrf")
        
        // Redis Session Store
        let redisCache = try RedisCache(config: self)
        let sessions = CacheSessions(redisCache, defaultExpiration: 86400)
        addConfigurable(middleware: SessionsMiddleware(sessions), name: "redis-sessions")
        
        // User Public File
        let userFileMiddleware = UserFileMiddleware(publicDir: publicDir, userPublicDir: userPublicDir)
        addConfigurable(middleware: userFileMiddleware, name: "userfile")
        
        // leaf
        addConfigurable(view: { config in UserLeafRenderder(viewsDir: config.viewsDir, userDir: config.userViewDir.finished(with: "/")) }, name: "userleaf")
    }
    
    private func setupPreparations() throws {
        
        preparations = [
            Category.self,
            User.self,
            Post.self,
            Tag.self,
            SiteInfo.self,
            Pivot<Post, Tag>.self,
            PivotPostTag.self,
            ChangeContentLengthTo8192.self,
            TwitterAuth.self,
            Image.self,
            SupportStaticContent.self,
            AddHtmlToPost.self
        ]
    }
}
