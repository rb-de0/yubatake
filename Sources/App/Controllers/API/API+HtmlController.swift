import Vapor

extension API {
    
    final class HtmlController {
        
        func store(request: Request, form: ConvertedMarkdownForm) throws -> Html {
            return try form.makeHtml()
        }
    }
}
