import Swinject
import Vapor

class DropletAssembly: Assembly {
    
    private let hash: HashProtocol
    
    init(drop: Droplet) {
        hash = drop.hash
    }
    
    func assemble(container: Container) {
        
        let config = Configs.resolve(FileConfig.self)
        
        container.register(FileProtocol.self, name: "default") { _ in
            return DataFile(workDir: config.viewsDir)
        }
        
        container.register(FileProtocol.self, name: "user") { _ in
            return DataFile(workDir: config.userViewDir.finished(with: "/"))
        }
        
        container.register(ViewRenderer.self) { r in
            return UserLeafRenderder(file: r.resolve(FileProtocol.self, name: "default")!, userFile: r.resolve(FileProtocol.self, name: "user")!)
        }.inObjectScope(.container)
        
        container.register(HashProtocol.self) { [hash] _ in
            return hash
        }.inObjectScope(.container)
    }
}
