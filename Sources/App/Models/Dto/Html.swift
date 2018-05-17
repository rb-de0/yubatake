import Vapor

final class Html: Content {
    
    let html: String
    
    init(content: String) throws {

        guard let html = content.htmlFromMarkdown else {
            throw Abort(.badRequest)
        }
        
        self.html = html
    }
}
