import Fluent
import Vapor

func routes(_ app: Application) throws {
    let root = app.routes.grouped(User.sessionAuthenticator())
    try root.register(collection: PublicRoutes())
    try root.register(collection: AdminRoutes())
    try root.register(collection: APIRoutes())
}
