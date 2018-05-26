import Vapor

struct Theme: Content, Parameter {
    
    let name: String
    let selected: Bool
    
    static func resolveParameter(_ parameter: String, on container: Container) throws -> Future<Theme> {
        let path = try parameter.requireAllowedPath()
        let repository = try container.make(FileRepository.self)
        guard repository.isExistTheme(name: path) else {
            throw Abort(.notFound)
        }
        
        return container.withPooledConnection(to: .mysql) { conn in
            try SiteInfo.shared(on: conn).map { Theme(name: path, selected: path == $0.selectedTheme) }
        }
    }
}
