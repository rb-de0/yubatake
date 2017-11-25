import Vapor

extension Droplet {
    func setupRoutes() throws {
        
        resource("posts", PostController())
        
        try collection(AdminRoutes.self)
    }
}
