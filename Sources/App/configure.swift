import CSRF
import Fluent
import FluentMySQLDriver
import Leaf
import Vapor
import VaporSecurityHeaders
import Redis

public func configure(_ app: Application) throws {

    // set working directory
    app.directory = DirectoryConfiguration(workingDirectory: .workingDirectory)

    // register configs
    try app.register(applicationConfig: ConfigJSONLoader.load(for: app, name: "app"))
    try app.register(mysqlDatabaseConfig: ConfigJSONLoader.load(for: app, name: "mysql"))
    app.register(fileConfig: FileConfig(directory: app.directory))

    // register services
    app.register(imageRepository: DefaultImageRepository(fileConfig: app.fileConfig))
    app.register(imageNameGenerator: DefaultImageNameGenerator())
    app.register(fileRepository: DefaultFileRepository(fileConfig: app.fileConfig))

    // twitter
    app.register(twitterRepository: DefaultTwitterRepository(applicationConfig: app.applicationConfig))

    // password
    if app.environment == .development {
        app.passwords.use(.stupid)
    } else {
        app.passwords.use(.bcrypt)
    }

    // views
    app.leaf.cache.isEnabled = false
    app.leaf.tags["count"] = CountTag()
    app.leaf.tags["date"] = DateTag()
    app.views.use(.leaf)
    app.register(viewCreator: .default())
    
    // redis
    app.redis.configuration = try RedisConfiguration(hostname: "127.0.0.1")

    // session
    if app.applicationConfig.useRedis == true {
        app.sessions.use(.redis)
    } else {
        app.sessions.use(.memory)
    }

    // middleware
    let cspConfig: CSPConfig = try ConfigJSONLoader.load(for: app, name: "csp")
    let cspHeaders = cspConfig.makeHeader()
    let securityHeaders = SecurityHeadersFactory()
        .with(contentSecurityPolicy: .init(value: cspHeaders))
        .build()
    app.middleware.use(securityHeaders)
    app.middleware.use(PublicFileMiddleware(base: FileMiddleware(publicDirectory: app.directory.publicDirectory)))
    app.middleware.use(app.sessions.middleware)
    let csrfMiddleware = CSRF(tokenRetrieval: { request in
        request.body.collect(max: nil).flatMap { _ in
            do {
                return request.eventLoop.future(try request.content.get(String.self, at: "csrfToken"))
            } catch {
                return request.eventLoop.makeFailedFuture(Abort(.forbidden, reason: "No CSRF token provided."))
            }
        }
    })
    app.middleware.use(csrfMiddleware)

    // database
    let mysqlConfig = app.mysqlDatabaseConfig
    let mysqlConfiguration = MySQLConfiguration(hostname: mysqlConfig.hostname,
                                                username: mysqlConfig.username,
                                                password: mysqlConfig.password,
                                                database: mysqlConfig.database,
                                                tlsConfiguration: nil)
    app.databases.use(.mysql(configuration: mysqlConfiguration), as: .mysql, isDefault: true)

    // migrations
    app.migrations.add(CreateUser())
    app.migrations.add(CreateCategory())
    app.migrations.add(CreateTag())
    app.migrations.add(CreatePost())
    app.migrations.add(CreatePostTag())
    app.migrations.add(CreateSiteInfo())
    app.migrations.add(CreateImage())

    // lifecycles
    app.lifecycle.use(InitialDataProvider())

    // routes
    app.routes.defaultMaxBodySize = "10mb"
    try routes(app)
}

extension String {
    static var workingDirectory: String {
        return #file.components(separatedBy: "/Sources/App").first ?? ""
    }
}
