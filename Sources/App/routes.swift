import Vapor

public func routes(_ app: Application) throws {
    let root = app.routes.grouped(app.fluent.sessions.middleware(for: User.self))
    try root.register(collection: PublicRoutes())
    try root.register(collection: AdminRoutes())
    try root.register(collection: APIRoutes())
}
