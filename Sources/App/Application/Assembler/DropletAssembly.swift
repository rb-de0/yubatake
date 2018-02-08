import Swinject
import Vapor

class DropletAssembly: Assembly {
    
    private let hash: HashProtocol
    private let view: ViewRenderer
    
    init(drop: Droplet) {
        hash = drop.hash
        view = drop.view
    }
    
    func assemble(container: Container) {
        
        container.register(ViewRenderer.self) { [view] r in
            return view
        }.inObjectScope(.container)
        
        container.register(HashProtocol.self) { [hash] r in
            return hash
        }.inObjectScope(.container)
    }
}
