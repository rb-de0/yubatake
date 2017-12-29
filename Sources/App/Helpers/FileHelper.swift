import Foundation
import Vapor

final class FileHelper: ApplicationHelper {
    
    static let imageRelativePath = "/documents/imgs"
    static var publicDir: String!
    
    static func setup(_ drop: Droplet) {
        publicDir = drop.config.publicDir
    }
    
    class func saveImage(data: Data, at path: String) throws {
        
        let result = FileManager.default.createFile(atPath: publicDir.finished(with: "/") + path, contents: data, attributes: nil)
        
        guard result else {
            throw IOError.sameNameAlreadyExist
        }
    }
    
    class func deleteImage(at path: String) throws {
        try FileManager.default.removeItem(atPath: publicDir.finished(with: "/") + path)
    }
}
