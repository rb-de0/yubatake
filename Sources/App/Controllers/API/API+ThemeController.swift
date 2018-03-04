import HTTP
import Vapor

extension API {
    
    final class ThemeController:  ResourceRepresentable {
        
        func makeResource() -> Resource<String> {
            return Resource(
                index: index,
                store: store
            )
        }
        
        static let themesKey = "themes"
        static let nameKey = "name"
        
        private lazy var fileRepository = resolve(FileRepository.self)
        
        func index(request: Request) throws -> ResponseRepresentable {
            let themes = try fileRepository.getAllThemes()
            var json = JSON()
            try json.set(ThemeController.themesKey, themes)
            return json
        }
        
        func store(request: Request) throws -> ResponseRepresentable {
            
            guard let name = request.data[ThemeController.nameKey]?.string else {
                throw Abort(.badRequest)
            }
            
            try fileRepository.saveTheme(as: name)
            
            return Response(status: .ok)
        }
        
        func apply(request: Request) throws -> ResponseRepresentable {
            
            guard let name = request.data[ThemeController.nameKey]?.string else {
                throw Abort(.badRequest)
            }
            
            try fileRepository.copyTheme(name: name)
            
            return Response(status: .ok)
        }
        
        func destroy(request: Request) throws -> ResponseRepresentable {
            
            guard let name = request.data[ThemeController.nameKey]?.string else {
                throw Abort(.badRequest)
            }
            
            try fileRepository.deleteTheme(name: name)
            
            return Response(status: .ok)
        }
    }
}
