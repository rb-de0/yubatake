import Vapor
import HTTP

extension Response {
    
    convenience init(redirect location: String, withErrorMessage errorMessage: String, for request: Request) {
        try? request.session?.data.set("error_message", errorMessage)
        self.init(redirect: location)
    }
}
