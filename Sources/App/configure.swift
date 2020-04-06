import Fluent
import FluentMySQLDriver
import Leaf
import Redis
import Vapor

public func configure(_ app: Application) throws {

    // set working directory
    app.directory = DirectoryConfiguration(workingDirectory: .workingDirectory)

    // register configs
    try app.register(applicationConfig: ConfigJSONLoader.load(fo: app, name: "app"))
    try app.register(mysqlDatabaseConfig: ConfigJSONLoader.load(fo: app, name: "mysql"))
    app.register(fileConfig: FileConfig(directory: app.directory))

    // register services
    app.register(imageRepository: DefaultImageRepository(fileConfig: app.fileConfig))
    app.register(imageNameGenerator: DefaultImageNameGenerator())
    app.register(fileRepository: DefaultFileRepository(fileConfig: app.fileConfig))

    // twitter
    app.register(twitterRepository: DefaultTwitterRepository(applicationConfig: app.applicationConfig))

    // auth
    if app.environment == .development {
        app.register(passwordVerifier: StupidPasswordVeryfier())
    } else {
        app.register(passwordVerifier: Bcrypt)
    }

    // views
    app.leaf.cache.isEnabled = false
    app.leaf.tags["count"] = CountTag()
    app.leaf.tags["date"] = DateTag()
    app.views.use(.leaf)
    app.register(viewCreator: .default())

    // middleware
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(SessionsMiddleware(session: app.sessions.memory))

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

    // create initial data
    if !app.environment.commandInput.arguments.contains("migrate") {
        try createInitialData(app)
    }

    // routes
    try routes(app)
}

private func createInitialData(_ app: Application) throws {
    try createRootUserIfNeeded(app)
        .flatMap { _ -> EventLoopFuture<Void> in
            createSiteInfoIfNeeded(app)
        }
        .wait()
}

private func createRootUserIfNeeded(_ app: Application) -> EventLoopFuture<Void> {
    return User.query(on: app.db).count()
        .flatMap { count -> EventLoopFuture<Void> in
            guard count == 0 else {
                return app.eventLoopGroup.future()
            }
            do {
                let rootUser = try User.makeRootUser(using: app)
                return rootUser.user.save(on: app.db).transform(to: ())
                    .always { result in
                        switch result {
                        case .success:
                            app.logger.warning("Root user created.")
                            app.logger.warning("Username: root")
                            app.logger.warning("Password: \(rootUser.rawPassword)")
                        default: break
                        }
                    }
            } catch {
                return app.eventLoopGroup.future(error: error)
            }
        }
}

private func createSiteInfoIfNeeded(_ app: Application) -> EventLoopFuture<Void> {
    return SiteInfo.query(on: app.db).count()
        .flatMap { count -> EventLoopFuture<Void> in
            guard count == 0 else {
                return app.eventLoopGroup.future()
            }
            let siteInfo = SiteInfo(name: "SiteTitle", description: "Please set up a sentence describing your site.")
            return siteInfo.save(on: app.db).transform(to: ())
                .always { result in
                    switch result {
                    case .success:
                        app.logger.info("SiteInfo created.")
                    default: break
                    }
                }
        }
}

extension String {
    static var workingDirectory: String {
        return #file.components(separatedBy: "/Sources/App").first ?? ""
    }
}
