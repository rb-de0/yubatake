import HTTP
import Vapor

final class Html: JSONRepresentable {
    
    static let htmlKey = "html"
    
    let html: String
    
    init(request: Request) throws {
        
        guard let content = request.data[Post.contentKey]?.string else {
            throw Abort(.badRequest)
        }
        
        guard let html = try HtmlHelper.html(from: content) else {
            throw Abort(.badRequest)
        }
        
        self.html = html
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Html.htmlKey, html)
        return json
    }
}
