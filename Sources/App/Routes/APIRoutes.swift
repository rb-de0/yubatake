import Vapor

final class APIRoutes: RouteCollection {

    func boot(routes: RoutesBuilder) throws {

        let api = routes
            .grouped("api")
            .grouped(AuthErrorMiddleware<User>())

        // images
        do {
            let controller = API.ImageController()
            api.get("images", use: controller.index)
            api.post("images", use: controller.store)
        }

        // themes
        do {
            let controller = API.ThemeController()
            api.get("themes", use: controller.index)
            api.post("themes", use: controller.store)
        }

        // files
        do {
            let controller = API.FileController()
            api.get("themes", ":name", "files", use: controller.index)
            api.get("files", use: controller.show)
            api.post("files", use: controller.store)
        }
    }
}
