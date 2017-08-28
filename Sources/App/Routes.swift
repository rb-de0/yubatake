import Vapor

extension Droplet {
    func setupRoutes() throws {
        
        resource("posts", PostController())
        
        // TODO: Remove
        try collection(ViewRoutes(view: view))
    }
}
