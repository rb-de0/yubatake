import Foundation

protocol ImageRepository {
    
    func isExist(at path: String) -> Bool
    
    func saveImage(data: Data, at path: String) throws
    func deleteImage(at path: String) throws
    func renameImage(at path: String, to afterPath: String) throws
}
