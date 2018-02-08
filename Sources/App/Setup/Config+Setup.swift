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

        try setupApplicationConfig()
        try setupProviders()
        try setupConfigurable()
        try setupPreparations()
    }
    
    private func setupApplicationConfig() throws {
        try Configs.register(config: ApplicationConfig(config: self))
        try Configs.register(config: CSPConfig(config: self))
        try Configs.register(config: FileConfig(config: self))
    }
    
    private func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
        try addProvider(MySQLProvider.Provider.self)
    }
    
    private func setupConfigurable() throws {
        
        // resolve configs
        let cspConfig = Configs.resolve(CSPConfig.self)
        let fileConfig = Configs.resolve(FileConfig.self)
        
        // Security Headers
        let securityHeadersFactory = SecurityHeadersFactory()
        securityHeadersFactory.with(contentSecurityPolicy: ContentSecurityPolicyConfiguration(value: cspConfig.makeConfigirationString()))
        addConfigurable(middleware: securityHeadersFactory.builder(), name: "security-headers")
        
        // CSRF
        let csrf = CSRF { request in request.data["csrf-token"]?.string ?? "" }
        addConfigurable(middleware: csrf, name: "csrf")
        
        // Redis Session Store
        let redisCache = try RedisCache(config: self)
        let sessions = CacheSessions(redisCache, defaultExpiration: 86400)
        addConfigurable(middleware: SessionsMiddleware(sessions), name: "redis-sessions")
        
        // User Public File
        let userFileMiddleware = UserFileMiddleware(publicDir: publicDir, userPublicDir: fileConfig.userPublicDir)
        addConfigurable(middleware: userFileMiddleware, name: "userfile")
        
        // leaf
        let userLeafRenderer = UserLeafRenderder(viewsDir: viewsDir, userDir: fileConfig.userViewDir.finished(with: "/"))
        addConfigurable(view: { _ in userLeafRenderer }, name: "userleaf")
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
