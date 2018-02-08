import Swinject
import Vapor

final class Configs {
    
    private static let container = Container()

    class func register<T: ConfigInitializable>(config: T) {
        container.register(T.self, factory: { _ in config })
    }
    
    class func resolve<T: ConfigInitializable>(_ type: T.Type) -> T {
        
        guard let config = container.resolve(type) else {
            fatalError()
        }
        
        return config
    }
}
