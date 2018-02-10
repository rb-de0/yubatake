import Foundation
import FluentProvider

extension Timestampable {
    
    func formattedCreatedAt(dateFormat: String) -> String? {

        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        
        return createdAt.map { formatter.string(from: $0) }
    }
    
    func formattedUpdatedAt(dateFormat: String) -> String? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        
        return updatedAt.map { formatter.string(from: $0) }
    }
}
