import Vapor

final class UserDataFile: FileProtocol {
    
    private let file: FileProtocol
    private let userFile: FileProtocol
    
    init(file: FileProtocol, userFile: FileProtocol) {
        self.file = file
        self.userFile = userFile
    }
    
    func read(at path: String) throws -> Bytes {
        do {
            let file = try userFile.read(at: path)
            return file
        } catch {
            return try file.read(at: path)
        }
    }
    
    func write(_ bytes: Bytes, to path: String) throws {
        fatalError("This method is not necessary for Leaf")
    }
    
    func delete(at path: String) throws {
        fatalError("This method is not necessary for Leaf")
    }
}
