@_exported import Vapor
import LeafProvider

extension Droplet {
    
    public func setup() throws {

        App.register(assembly: RepositoryAssembly())
        App.register(assembly: DropletAssembly(drop: self))
        
        // register leaf tags
        registerTags()
        
        // create root user at the first time
        try createRootUserIfNeeded()
        
        // create site info at the first time
        try createSiteInfoIfNeeded()
        
        // setup routing
        try setupRoutes()
    }
    
    private func registerTags() {
        (view as? UserLeafRenderder)?.stem.register(Escape())
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
    
    private func createSiteInfoIfNeeded() throws {
        
        guard try SiteInfo.count() == 0 else {
            return
        }
        
        let siteInfo = SiteInfo(name: "SiteTitle", description: "Please set up a sentence describing your site.")
        try siteInfo.save()
    }
}
