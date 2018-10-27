import Vapor

extension Environment {
    
    var isDevelopment: Bool {
        return name == "development"
    }
}
