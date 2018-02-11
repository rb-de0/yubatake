import Swinject
import Vapor

// Register some of the services provided by Droplet in the container
class DropletAssembly: Assembly {
    
    private let hash: HashProtocol
    
    init(drop: Droplet) {
        hash = drop.hash
    }
    
    func assemble(container: Container) {

        container.register(HashProtocol.self) { [hash] _ in
            return hash
        }.inObjectScope(.container)
    }
}
