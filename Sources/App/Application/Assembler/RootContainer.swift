import Swinject

private let rootContainer = Container()
private let assembler = Assembler()

func register(assembly: Assembly) {
    assembler.apply(assembly: assembly)
}

func register<Service>(_ service: Service) {
    rootContainer.register(type(of: service), factory: { _ in service })
}

func resolve<Service>(_ type: Service.Type, name: String? = nil) -> Service {
    
    guard let service = assembler.resolver.resolve(type, name: name) else {
        fatalError()
    }
    
    return service
}
