@testable import App
import CSRF
import FluentMySQL
import Leaf
import Vapor
import XCTest

final class ApplicationBuilder {
    
    class func build(forAdminTests: Bool, envArgs: [String]? = nil, configForTest: Config = .default(), servicesForTest: Services = .default()) throws -> Application {
        
        var config = configForTest
        var env = try Environment.detect()
        var services = servicesForTest
        
        if let environmentArgs = envArgs {
            env.arguments = environmentArgs
        }
        
        try App.configure(&config, &env, &services)
        
        let mysqlDatabaseConfig = MySQLDatabaseConfig(hostname: DB.hostName, port: DB.port, username: DB.user, password: DB.password, database: "note_tests")
        services.register(mysqlDatabaseConfig)

        services.register(TestViewDecorator())
        services.register { container -> ViewCreator in
            let original = try ViewCreator.default(container: container)
            return ViewCreator(renderer: original.renderer, decorators: original.decorators + [try container.make(TestViewDecorator.self)])
        }
        
        services.register(DatabaseConnectionPoolConfig(maxConnections: 100))
        
        if forAdminTests {
            services.register(AlwaysAuthMiddleware())
        
            var middlewares = MiddlewareConfig()
            middlewares.use(AlwaysAuthMiddleware.self)
            middlewares.use(CSRF.self)
            middlewares.use(MessageDeliveryMiddleware.self)
            middlewares.use(SessionsMiddleware.self)
            middlewares.use(FileMiddleware.self)
            middlewares.use(DateMiddleware.self)
            middlewares.use(ErrorMiddleware.self)
            services.register(middlewares)
        }

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
