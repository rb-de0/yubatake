@testable import App
import CSRF
import FluentMySQL
import Leaf
import Redis
import Vapor
import VaporSecurityHeaders
import XCTest

final class ApplicationBuilder {
    
    class func build(forAdminTests: Bool, envArgs: [String]? = nil, customize: ((Config, Services) -> (Config, Services))? = nil) throws -> Application {
        
        var config = Config.default()
        var env = try Environment.detect()
        var services = Services.default()
        
        if let environmentArgs = envArgs {
            env.arguments = environmentArgs
        }
        
        try App.configure(&config, &env, &services)
        
        if let _customize = customize {
            let customized = _customize(config, services)
            config = customized.0
            services = customized.1
        }
        
        let mysqlDatabaseConfig = MySQLDatabaseConfig(hostname: DB.hostName, port: DB.port, username: DB.user, password: DB.password, database: "yubatake_tests")
        services.register(mysqlDatabaseConfig)
        
        let redisClientConfig = RedisClientConfig(url: URL(string: "redis://user:pass@localhost:6379")!)
        services.register(redisClientConfig)
        
        services.register(TestViewDecorator())
        services.register { container -> ViewCreator in
            let original = try ViewCreator.default()
            return try ViewCreator.default(decorators: original.decorators + [try container.make(TestViewDecorator.self)])
        }
        
        services.register(DatabaseConnectionPoolConfig(maxConnections: 100))
        
        if forAdminTests {
            services.register(AlwaysAuthMiddleware())
        
            var middlewares = MiddlewareConfig()
            middlewares.use(SecurityHeaders.self)
            middlewares.use(ErrorMiddleware.self)
            middlewares.use(PublicFileMiddleware.self)
            middlewares.use(SessionsMiddleware.self)
            middlewares.use(MessageDeliveryMiddleware.self)
            middlewares.use(CSRF.self)
            middlewares.use(AlwaysAuthMiddleware.self)
            services.register(middlewares)
        }
        
        config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)

        let app = try Application(
            config: config,
            environment: env,
            services: services
        )
        
        try App.boot(app)
        
        return app
    }
    
    class func clear() throws {
        try build(forAdminTests: false, envArgs: ["vapor", "revert", "--all", "-y"]).asyncRun().wait()
    }
}
