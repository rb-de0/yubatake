import Vapor
import Leaf

protocol ViewDecorator {
    func decorate(context: inout [String: TemplateData], for request: Request) throws
}
