import Vapor

extension API {
    
    final class ThemeController {
        
        func index(request: Request) throws -> Future<[Theme]> {
            let repository = try request.make(FileRepository.self)
            let themes = try repository.allThemes()
            return try SiteInfo.shared(on: request).map { siteInfo in
                themes.map { Theme(name: $0, selected: $0 == siteInfo.selectedTheme)}
            }
        }
        
        func store(request: Request, form: ThemeForm) throws -> Future<HTTPStatus> {
            
            return try SiteInfo.shared(on: request).flatMap { siteInfo in
                
                siteInfo.theme = form.name
                
                return request.withPooledConnection(to: .mysql) { conn in
                    siteInfo.save(on: conn).transform(to: .ok)
                }
            }
        }
    }
}
