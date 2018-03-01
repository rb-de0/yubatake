import Crypto
import Foundation
import HTTP

final class ImageData {
    
    static let imageNameKey = "image_file_name"
    static let imageDateKey = "image_file_data"
    
    static let fileNameLength = 16
    
    private lazy var imageRepository = resolve(ImageRepository.self)
    
    let data: Bytes
    let name: String
    let path: String
    
    init(request: Request) throws {
        
        guard let data = request.data[ImageData.imageDateKey]?.bytes,
            let name = request.data[ImageData.imageNameKey]?.string else {
            
            throw Abort(.badRequest)
        }
        
        let config = Configs.resolve(FileConfig.self)
        self.data = data
        self.name = name
        self.path = config.imageRelativePath.started(with: "/").finished(with: "/").appending(name)
    }
    
    func save() throws {
        try imageRepository.saveImage(data: Data(bytes: data), at: path)
    }
}
