import Core
import Foundation
import Service

protocol LocalConfig: Decodable {
    static var fileName: String { get }
}

final class ConfigProvider: Service {
    
    private struct Constant {
        static let configDir = "Config"
        static let secretsDir = "secrets"
        static let configExtension = "json"
    }
    
    private let configData: [String: Data]
    
    init(directoryConfig: DirectoryConfig, environment: Environment) throws {
        
        let configDir = directoryConfig.workDir.finished(with: "/") + Constant.configDir
        let targetDirs = ["", Constant.secretsDir, environment.name]
        var configData = [String: Data]()
        
        for targetDir in targetDirs {
            
            let searchPath = configDir.finished(with: "/") + targetDir
            
            guard FileManager.default.fileExists(atPath: searchPath) else {
                continue
            }
            
            let contents = try FileManager.default
                .contentsOfDirectory(atPath: searchPath)
                .filter { $0.hasSuffix(Constant.configExtension) }
            
            for content in contents {
                
                let contentPath = searchPath.finished(with: "/") + content
                let contentName = String(content.dropLast(Constant.configExtension.count + 1))
                
                guard let data = FileManager.default.contents(atPath: contentPath) else {
                    continue
                }
                
                configData[contentName] = data
            }
        }
        
        self.configData = configData
    }
    
    func make<T: LocalConfig>(_ type: T.Type) throws -> T {
        
        guard let data = configData[T.fileName] else {
            fatalError()
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}
