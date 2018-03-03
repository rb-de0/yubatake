@testable import App
import Foundation

class TestThemeRepository: FileRepository {
    
    func readFileData(in theme: String?, at path: String, type: FileType, customized: Bool) throws -> String {
        return ""
    }
    
    func writeUserFileData(at path: String, type: FileType, data: String) throws {
        fatalError("Not Implemented")
    }
    
    func deleteUserFileData(at path: String, type: FileType) throws {
        fatalError("Not Implemented")
    }
    
    func deleteAllUserFiles() throws {
        fatalError("Not Implemented")
    }
    
    func files(in theme: String?) -> [AccessibleFileGroup] {
        fatalError("Not Implemented")
    }
    
    func getAllThemes() throws -> [String] {
        return []
    }
    
    func saveTheme(as name: String) throws {}
    
    func copyTheme(name: String) throws {}
    
    func deleteTheme(name: String) throws {}
}
