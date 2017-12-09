import HTTP
import Vapor

extension Response {
    
    convenience init(redirect location: String, withError error: Error, for request: Request) {
        
        let errorMessage = (error as? Debuggable)?.reason ?? error.localizedDescription
        
        try? request.session?.data.set("error_message", errorMessage)
        self.init(redirect: location)
    }
}
