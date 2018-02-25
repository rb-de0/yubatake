import Swinject
import Vapor

class ViewAssembly: Assembly {
    
    private let viewCreator: DefaultViewCreator
    
    init(drop: Droplet) {
        viewCreator = DefaultViewCreator(renderer: drop.view)
        viewCreator.set(drop.config.viewDecorators)
    }
    
    func assemble(container: Container) {
        
        container.register(ViewCreator.self) { [viewCreator] _ in
            return viewCreator
        }.inObjectScope(.container)
    }
}

