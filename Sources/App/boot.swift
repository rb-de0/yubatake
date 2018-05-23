import Vapor

public func boot(_ app: Application) throws {
    try createRootUserIfNeeded(using: app)
        .flatMap {
            try createSiteInfoIfNeeded(using: app)
        }
        .wait()
}

private func createRootUserIfNeeded(using app: Application) throws -> Future<Void> {
    
    let logger = try app.make(Logger.self)
    
    return app.withPooledConnection(to: .mysql) { conn -> Future<Void> in
        User.query(on: conn).count()
            .flatMap {  count -> Future<Void> in
                if count == 0 {
                    let rootUser = try User.makeRootUser(using: app)
                    return rootUser.user.save(on: conn).transform(to: ()).do {
                        logger.warning("Root user created.")
                        logger.warning("Username: root")
                        logger.warning("Password: \(rootUser.rawPassword)")
                    }
                }
                return conn.eventLoop.newSucceededFuture(result: ())
            }
    }
}

private func createSiteInfoIfNeeded(using app: Application) throws -> Future<Void> {
    
    let logger = try app.make(Logger.self)
    
    return app.withPooledConnection(to: .mysql) { conn -> Future<Void> in
        SiteInfo.query(on: conn).count()
            .flatMap { count -> Future<Void> in
                if count == 0 {
                    let siteInfo = SiteInfo(name: "SiteTitle", description: "Please set up a sentence describing your site.")
                    return siteInfo.save(on: conn).transform(to: ()).do {
                        logger.info("SiteInfo created.")
                    }
                }
                return conn.eventLoop.newSucceededFuture(result: ())
            }
    }
}
