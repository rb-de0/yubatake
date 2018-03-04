@testable import App
import Foundation

class TestFileRepository: FileRepository {
    
    func readFileData(in theme: String?, at path: String, type: FileType, customized: Bool) throws -> String {
        return ""
    }
    
    func writeUserFileData(at path: String, type: FileType, data: String) throws {}
    
    func deleteUserFileData(at path: String, type: FileType) throws {}
    
    func deleteAllUserFiles() throws {}
    
    func files(in theme: String?) -> [AccessibleFileGroup] {
        return []
    }
    
    func getAllThemes() throws -> [String] {
        fatalError("Not Implemented")
    }
    
    func saveTheme(as name: String) throws {
        fatalError("Not Implemented")
    }
    
    func copyTheme(name: String) throws {
        fatalError("Not Implemented")
    }
    
    func deleteTheme(name: String) throws {
        fatalError("Not Implemented")
    }
}
