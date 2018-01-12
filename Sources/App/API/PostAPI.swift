import HTTP
import Vapor

struct PostAPI {
    
    struct GetHTMLFromMarkdown {
        
        struct Input {
            let content: String
            init(request: Request) {
                content = request.data[Post.contentKey]?.string ?? ""
            }
        }
        
        struct Output {
            static let htmlKey = "html"
            let html: String
            func makeJSON() throws -> JSON {
                var json = JSON()
                try json.set(Output.htmlKey, html)
                return json
            }
        }
        
        func handleRequest(request: Request) throws -> ResponseRepresentable {
            let input = Input(request: request)
            let html = try HtmlHelper.html(from: input.content) ?? ""
            return try Output(html: html).makeJSON()
        }
    }
}
