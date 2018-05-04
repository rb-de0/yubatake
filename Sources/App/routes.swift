import Routing
import Vapor
import Leaf

public func routes(_ router: Router) throws {
    let root = router.grouped(User.authSessionsMiddleware())
    try root.register(collection: PublicRoutes())
    try root.register(collection: AdminRoutes())
    try root.register(collection: APIRoutes())
}
