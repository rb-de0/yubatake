import Authentication
import CSRF
import Crypto
import FluentMySQL
import Leaf
import Redis
import Vapor
import VaporSecurityHeaders

public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
    ) throws {
    
    let environment = env
    
    // configs
    services.register { container -> ConfigProvider in
        return try ConfigProvider(directoryConfig: container.make(), environment: environment)
    }
    services.register { container -> ApplicationConfig in
        return try container.make(ConfigProvider.self).make(ApplicationConfig.self)
    }
    services.register { container -> CSPConfig in
        return try container.make(ConfigProvider.self).make(CSPConfig.self)
    }
    
    // bcrypt
    try services.register(AuthenticationProvider())
    config.prefer(BCryptDigest.self, for: PasswordVerifier.self)
    
    // session store
    // TODO: Redis
    
    // router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    // command
    services.register { container -> CommandConfig in
        var config = CommandConfig.default()
        config.use(MigrationCommand.self, as: "migrate")
        config.useFluentCommands()
        return config
    }
    services.register(MigrationCommand())
    
    // view
    do {
        try services.register(LeafProvider())
        config.prefer(LeafRenderer.self, for: TemplateRenderer.self)

        services.register { container -> ViewCreator in
            try ViewCreator.default(container: container)
        }
        
        var tags = LeafTagConfig.default()
        tags.use(Raw(), as: "raw")
        services.register(tags)
    }
    
    // middleware
    let handler: TokenRetrievalHandler = { request in request.content.get(at: "csrf-token") }
    services.register(CSRF(tokenRetrieval: handler))
    services.register(MessageDeliveryMiddleware())
    services.register { container -> SecurityHeaders in
        let cspConfig = try container.make(CSPConfig.self)
        let headerValue = cspConfig.makeHeader()
        let securityHeadersFactory = SecurityHeadersFactory()
            .with(contentSecurityPolicy: ContentSecurityPolicyConfiguration(value: headerValue))
        return securityHeadersFactory.build()
    }
    
    var middlewares = MiddlewareConfig()
    middlewares.use(SecurityHeaders.self)
    middlewares.use(ErrorMiddleware.self)
    middlewares.use(FileMiddleware.self)
    middlewares.use(SessionsMiddleware.self)
    middlewares.use(MessageDeliveryMiddleware.self)
    middlewares.use(CSRF.self)
    
    services.register(middlewares)
    
    // repository
    services.register(ImageRepository.self) { container in
        ImageRepositoryDefault(directoryConfig: try container.make())
    }
    
    services.register(TwitterRepository.self) { container in
        try TwitterRepositoryDefault(applicationConfig: try container.make())
    }
    
    // database
    try services.register(FluentMySQLProvider())
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
    
    services.register(DatabaseConnectionPoolConfig(maxConnections: 100))
    
    services.register { container -> MySQLDatabaseConfig in
        return try container.make(ConfigProvider.self).make(MySQLDatabaseConfig.self)
    }

    services.register { container -> DatabasesConfig in
        let mysqlConfig = try container.make(MySQLDatabaseConfig.self)
        let mysql = MySQLDatabase(config: mysqlConfig)
        var databaseConfig = DatabasesConfig()
        databaseConfig.add(database: mysql, as: .mysql)
        return databaseConfig
    }
    
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .mysql)
    migrations.add(model: Category.self, database: .mysql)
    migrations.add(model: Tag.self, database: .mysql)
    migrations.add(model: Post.self, database: .mysql)
    migrations.add(model: PostTag.self, database: .mysql)
    migrations.add(model: SiteInfo.self, database: .mysql)
    migrations.add(model: Image.self, database: .mysql)
    services.register(migrations)
}
