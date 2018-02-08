import Swinject

class RepositoryAssembly: Assembly {
    
    func assemble(container: Container) {
        
        container.register(TwitterRepository.self) { _ in
            return TwitterRepositoryImpl()
        }.inObjectScope(.container)
        
        container.register(FileRepository.self) { _ in
            return FileRepositoryImpl()
        }.inObjectScope(.container)
    }
}
