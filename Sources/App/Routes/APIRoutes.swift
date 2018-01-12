import Vapor
import AuthProvider

final class APIRoutes: RouteCollection, EmptyInitializable {
    
    func build(_ builder: RouteBuilder) throws {
        let api = builder.grouped("api")
        api.post("converted_markdown", handler: PostAPI.GetHTMLFromMarkdown().handleRequest)
    }
}
