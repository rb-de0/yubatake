import Vapor

struct ConvertedMarkdownForm: Form, Content {
    
    let content: String
    
    func makeHtml() throws -> Html {
        return try Html(content: content)
    }
}
