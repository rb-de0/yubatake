import Fluent
import Vapor

final class InitialDataProvider: LifecycleHandler {

    func didBoot(_ application: Application) throws {
        if application.environment.commandInput.arguments.contains("migrate") {
            return
        }
        try createRootUserIfNeeded(application)
            .flatMap { _ -> EventLoopFuture<Void> in
                createSiteInfoIfNeeded(application)
            }
            .wait()
    }
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
