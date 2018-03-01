@testable import App
import Foundation

class TestImageFileRepository: FileRepository {
    
    static var imageFiles = Set<String>()
    
    func saveImage(data: Data, at path: String) throws {
        TestImageFileRepository.imageFiles.insert(path)
    }
    
    func deleteImage(at path: String) throws {
        TestImageFileRepository.imageFiles.remove(path)
    }
    
    func renameImage(at path: String, to afterPath: String) throws {
        TestImageFileRepository.imageFiles.remove(path)
        TestImageFileRepository.imageFiles.insert(afterPath)
    }
    
    func writeUserFileData(at path: String, type: FileType, data: String) throws {
        fatalError("Not Implemented")
    }
    
    func deleteUserFileData(at path: String, type: FileType) throws {
        fatalError("Not Implemented")
    }
    
    func readFileData(at path: String, type: FileType) throws -> String {
        fatalError("Not Implemented")
    }
    
    func accessibleFiles() -> [AccessibleFileGroup] {
        fatalError("Not Implemented")
    }
    
    func isExistPublicResource(path: String) -> Bool {
        return TestImageFileRepository.imageFiles.contains(path)
    }
}
