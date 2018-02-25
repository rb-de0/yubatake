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
        try setupServices()
        try setupMiddlewares()
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
        try addProvider(LeafProvider.Provider.self)
    }
    
    private func setupServices() throws {
        
        let fileConfig = Configs.resolve(FileConfig.self)
        
        // User Leaf Renderer
        let defaultDataFile = DataFile(workDir: viewsDir)
        let userDataFile = DataFile(workDir: fileConfig.userViewDir.finished(with: "/"))
        let userLeafRenderer = UserLeafRenderder(file: defaultDataFile, userFile: userDataFile)
        userLeafRenderer.stem.register(Escape())
        addConfigurable(view: { _ in userLeafRenderer } , name: "userleaf")
    }
    
    private func setupMiddlewares() throws {
        
        // resolve configs
        let cspConfig = Configs.resolve(CSPConfig.self)
        let fileConfig = Configs.resolve(FileConfig.self)
        
        // User Public File
        let userFileBuilder: (Config) -> UserFileMiddleware = { config in
            UserFileMiddleware(publicDir: config.publicDir, userPublicDir: fileConfig.userPublicDir)
        }
        addConfigurable(middleware: { config in userFileBuilder(config) }, name: "userfile")
        
        // Redis Session Store
        let redisSessionBuilder: (Config) throws -> SessionsMiddleware = { config in
            let redisCache = try RedisCache(config: config)
            let sessions = CacheSessions(redisCache, defaultExpiration: 86400)
            return SessionsMiddleware(sessions)
        }
        addConfigurable(middleware: { config in try redisSessionBuilder(config) }, name: "redis-sessions")
        
        // Security Headers
        let securityHeadersFactory = SecurityHeadersFactory()
        securityHeadersFactory.with(contentSecurityPolicy: ContentSecurityPolicyConfiguration(value: cspConfig.makeConfigirationString()))
        addConfigurable(middleware: securityHeadersFactory.builder(), name: "security-headers")
        
        // CSRF
        let tokenRetrieval: TokenRetrievalHandler = { request in request.data["csrf-token"]?.string ?? "" }
        addConfigurable(middleware: { config in CSRF(config: config, tokenRetrieval: tokenRetrieval) }, name: "csrf")
        
        // Message Deliver
        addConfigurable(middleware: { config in MessageDeliveryMiddleware(config: config) } , name: "message")
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
