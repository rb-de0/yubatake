import CSRF
import Vapor

struct CSRFViewDecorator: ViewDecorator {
    
    func decorate(context: inout [String : TemplateData], for request: Request) throws {
        let csrf = try request.make(CSRF.self).createToken(from: request)
        context["csrf_token"] = .string(csrf)
    }
}
