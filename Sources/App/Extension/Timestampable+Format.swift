import Fluent
import Foundation

extension Timestampable {
    
    func formattedCreatedAt(dateFormat: String) -> String? {

        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        
        return fluentCreatedAt.map { formatter.string(from: $0) }
    }
    
    func formattedUpdatedAt(dateFormat: String) -> String? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        
        return fluentUpdatedAt.map { formatter.string(from: $0) }
    }
}
