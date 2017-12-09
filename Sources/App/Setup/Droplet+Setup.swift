@_exported import Vapor

extension Droplet {
    
    public func setup() throws {
        
        // setup application helper
        setupHalpers([
            AdminViewContext.self,
            PublicViewContext.self,
            HashHelper.self
        ])
        
        // create root user at the first time
        try createRootUserIfNeeded()
        
        // setup routing
        try setupRoutes()
    }
    
    private func setupHalpers(_ helpers: [ApplicationHelper.Type]) {
        helpers.forEach {
            $0.setup(self)
        }
    }
    
    private func createRootUserIfNeeded() throws {
        
        guard try User.count() == 0 else {
            return
        }
        
        let (rootUser, rawPassword) = try User.makeRootUser()
        log.info("Root user created.")
        log.info("Username: root")
        log.info("Password: \(rawPassword)")
        try rootUser.save()
    }
}
