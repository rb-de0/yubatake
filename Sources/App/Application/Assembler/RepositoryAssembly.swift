import Swinject

class RepositoryAssembly: Assembly {
    
    func assemble(container: Container) {
        
        container.register(TwitterRepository.self) { r in
            return TwitterRepositoryImpl()
        }.inObjectScope(.container)
        
        container.register(FileRepository.self) { r in
            return FileRepositoryImpl()
        }.inObjectScope(.container)
    }
}
