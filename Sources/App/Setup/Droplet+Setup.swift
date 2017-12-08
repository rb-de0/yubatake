@_exported import Vapor

extension Droplet {
    
    public func setup() throws {
        
        // setup view context
        PublicViewContext.setUp(viewRenderer: view)
        AdminViewContext.setUp(viewRenderer: view)
        
        // create root user at first time
        try createRootUserIfNeeded()
        
        // setup routing
        try setupRoutes()
    }
    
    private func createRootUserIfNeeded() throws {
        
        guard try User.count() == 0 else {
            return
        }
        
        let (rootUser, rawPassword) = try User.makeRootUser(hash: hash)
        log.info("Root user created.")
        log.info("Username: root")
        log.info("Password: \(rawPassword)")
        try rootUser.save()
    }
}
