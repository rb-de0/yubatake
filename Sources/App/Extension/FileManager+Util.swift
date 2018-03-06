import Foundation

extension FileManager {
    
    func removeItemIfExist(atPath: String) throws {
        if fileExists(atPath: atPath) {
            try removeItem(atPath: atPath)
        }
    }
    
    func copyItemIfExist(atPath :String, toPath: String) throws {
        if fileExists(atPath: atPath) {
            try copyItem(atPath: atPath, toPath: toPath)
        }
    }
}
