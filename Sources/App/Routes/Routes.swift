import Vapor

extension Droplet {
    func setupRoutes() throws {
        
        let root = grouped(MessageDeliveryMiddleware())
        
        try root.collection(PublicRoutes.self)
        try root.collection(AdminRoutes.self)
        try root.collection(APIRoutes.self)
    }
}
