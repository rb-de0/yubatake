import Foundation

protocol FileRepository {
    
    func saveImage(data: Data, at path: String) throws
    func deleteImage(at path: String) throws
    func renameImage(at path: String, to afterPath: String) throws
    
    func writeUserFileData(at path: String, type: FileType, data: String) throws
    func deleteUserFileData(at path: String, type: FileType) throws
    func readFileData(at path: String, type: FileType) throws -> String
    
    func accessibleFiles() -> [AccessibleFileGroup]
    
    func isExist(path: String) -> Bool
}
