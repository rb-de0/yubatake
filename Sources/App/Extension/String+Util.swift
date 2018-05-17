import Foundation
import Vapor

extension String {
    
    func take(n: Int) -> String {
        
        if n >= self.count {
            return self
        }
        
        return String(self[..<index(self.startIndex, offsetBy: n)])
    }
    
    func started(with start: String) -> String {
        guard !self.hasPrefix(start) else { return self }
        return start + self
    }
    
    @discardableResult
    func requireAllowedPath() throws -> String {
        
        if contains("../") {
            throw Abort(.forbidden)
        }
        
        return self
    }
}
