import Vapor

extension Droplet {
    func setupRoutes() throws {
        resource("posts", PostController())
    }
}
