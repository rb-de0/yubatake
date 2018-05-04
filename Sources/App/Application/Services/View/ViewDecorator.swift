import Leaf
import Vapor

protocol ViewDecorator {
    func decorate(context: inout [String: TemplateData], for request: Request) throws
}
