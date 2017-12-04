@_exported import Vapor

extension Droplet {
    
    public func setup() throws {
        
        // setup view context
        PublicViewContext.setUp(viewRenderer: view)
        AdminViewContext.setUp(viewRenderer: view)
        
        // setup routing
        try setupRoutes()
    }
}
