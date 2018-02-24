@testable import App
import Foundation

class TestFileRepository: FileRepository {
    
    func saveImage(data: Data, at path: String) throws {
        fatalError("Not Implemented")
    }
    
    func deleteImage(at path: String) throws {
        fatalError("Not Implemented")
    }
    
    func renameImage(at path: String, to afterPath: String) throws {
        fatalError("Not Implemented")
    }
    
    func writeUserFileData(at path: String, type: FileType, data: String) throws {}
    
    func deleteUserFileData(at path: String, type: FileType) throws {}
    
    func readFileData(at path: String, type: FileType) throws -> String {
        return ""
    }
    
    func accessibleFiles() -> [AccessibleFileGroup] {
        return []
    }
    
    func isExist(path: String) -> Bool {
        return true
    }
}

