import Fluent

enum NoteEntityError: Error {
    case noIntergerId
}

extension Entity {
    
    func assertId() throws -> Int {
        
        guard let id = try assertExists().int else {
            throw NoteEntityError.noIntergerId
        }
        
        return id
    }
}
