import Foundation

final class ImageRepositoryImpl: ImageRepository, FileHandlable {
    
    let config: FileConfig
    
    init() {
        
        config = Configs.resolve(FileConfig.self)
        
        do {
            try createDirIfNeeded()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func isExist(at path: String) -> Bool {
        return FileManager.default.fileExists(atPath: filePath(at: path, type: .publicResource))
    }
    
    func saveImage(data: Data, at path: String) throws {
        
        let result = FileManager.default.createFile(atPath: filePath(at: path, type: .publicResource), contents: data, attributes: nil)
        
        guard result else {
            throw IOError.sameNameAlreadyExist
        }
    }
    
    func deleteImage(at path: String) throws {
        try FileManager.default.removeItem(atPath: filePath(at: path, type: .publicResource))
    }
    
    func renameImage(at path: String, to afterPath: String) throws {
        try FileManager.default.moveItem(atPath: filePath(at: path, type: .publicResource), toPath: filePath(at: afterPath, type: .publicResource))
    }
    
    private func createDirIfNeeded() throws {
        try FileManager.default.createDirectory(atPath: config.imageDir, withIntermediateDirectories: true, attributes: nil)
    }
}
