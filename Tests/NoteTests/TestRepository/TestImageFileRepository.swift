@testable import App
import Foundation

class TestImageFileRepository: ImageRepository {
    
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
    
    func isExist(at path: String) -> Bool {
        return TestImageFileRepository.imageFiles.contains(path)
    }
}
