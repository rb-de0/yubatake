@testable import App
import Vapor
import Fluent
import FluentMySQLDriver

final class ApplicationBuilder {
    
    class func build() throws -> Application {
        let app = Application(.testing)
        try configure(app, forAdmin: false, workingDirectory: .workingDirectory)
        return app
    }
    
    class func buildForAdmin(workingDirectory: String = .workingDirectory) throws -> Application {
        let app = Application(.testing)
        try configure(app, forAdmin: true, workingDirectory: workingDirectory)
        return app
    }
    
    class func migrate() throws {
        var env = Environment.testing
        env.arguments += ["migrate", "-y"]
        let app = Application(env)
        defer { app.shutdown() }
        try configureForMigrate(app)
        try app.run()
    }
    
    class func revert() throws {
        var env = Environment.testing
        env.arguments += ["migrate", "--revert", "-y"]
        let app = Application(env)
        defer { app.shutdown() }
        try configureForMigrate(app)
        try app.run()
    }
}

// configure for test
private func configure(_ app: Application, forAdmin: Bool, workingDirectory: String) throws {
    
    // set working directory
    app.directory = DirectoryConfiguration(workingDirectory: .workingDirectory)

    // register configs
    try app.register(applicationConfig: ConfigJSONLoader.load(for: app, name: "app"))
    try app.register(mysqlDatabaseConfig: ConfigJSONLoader.load(for: app, name: "mysql"))
    app.register(fileConfig: FileConfig(directory: DirectoryConfiguration(workingDirectory: workingDirectory)))

    // register services
    app.register(imageRepository: DefaultImageRepository(fileConfig: app.fileConfig))
    app.register(imageNameGenerator: DefaultImageNameGenerator())
    app.register(fileRepository: DefaultFileRepository(fileConfig: app.fileConfig))

    // twitter
    app.register(twitterRepository: DefaultTwitterRepository(applicationConfig: app.applicationConfig))

    // password
    app.passwords.use(.bcrypt)

    // views
    app.leaf.tags["count"] = CountTag()
    app.leaf.tags["date"] = DateTag()
    app.views.use(.leaf)
    app.register(testViewDecorator: TestViewDecorator())
    app.register(viewCreator: ViewCreator(decorators: [MessageDeliveryViewDecorator(), app.testViewDecorator]))
    
    // session
    app.sessions.use(.memory)

    // middleware
    app.middleware.use(PublicFileMiddleware(base: FileMiddleware(publicDirectory: app.directory.publicDirectory)))
    app.middleware.use(app.sessions.middleware)
    if forAdmin {
        app.middleware.use(AlwaysAuthMiddleware())
    }

    // database
    let mysqlConfiguration = MySQLConfiguration(hostname: DB.hostName,
                                                port: DB.port,
                                                username: DB.user,
                                                password: DB.password,
                                                database: "yubatake_tests",
                                                tlsConfiguration: nil)
    app.databases.use(.mysql(configuration: mysqlConfiguration), as: .mysql, isDefault: true)
    
    // lifecycles
    app.lifecycle.use(InitialDataProvider())

    // routes
    try routes(app)
}

// configure for migrate
private func configureForMigrate(_ app: Application) throws {
    
    // database
    let mysqlConfiguration = MySQLConfiguration(hostname: DB.hostName,
                                                port: DB.port,
                                                username: DB.user,
                                                password: DB.password,
                                                database: "yubatake_tests",
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
}
