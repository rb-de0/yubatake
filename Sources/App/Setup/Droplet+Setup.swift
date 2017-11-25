@_exported import Vapor

extension Droplet {
    
    public func setup() throws {
        
        // setup view creator
        AdminViewCreator.setUp(viewRenderer: view)
        
        // setup routing
        try setupRoutes()
    }
}
