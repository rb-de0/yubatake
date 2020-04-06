//@testable import App
//import Vapor
//
//final class TestImageFileRepository: ImageRepository, Service {
//    
//    static var imageFiles = Set<String>()
//    
//    func isExist(at name: String) -> Bool {
//        return TestImageFileRepository.imageFiles.contains(name)
//    }
//    
//    func save(image: Data, for name: String) throws {
//        TestImageFileRepository.imageFiles.insert(name)
//    }
//    
//    func delete(at name: String) throws {
//        TestImageFileRepository.imageFiles.remove(name)
//    }
//    
//    func rename(from name: String, to afterName: String) throws {
//        TestImageFileRepository.imageFiles.remove(name)
//        TestImageFileRepository.imageFiles.insert(afterName)
//    }
//}
