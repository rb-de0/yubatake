import Vapor

extension Droplet {
    func setupRoutes() throws {
        try collection(PublicRoutes.self)
        try collection(AdminRoutes.self)
        try collection(APIRoutes.self)
    }
}
