@testable import App
import Leaf
import Vapor

final class TestViewDecorator: ViewDecorator, Service {
    
    private var currentContext: TemplateData?
    
    func decorate(context: inout [String : TemplateData], for request: Request) throws {
        currentContext = TemplateData.dictionary(context)
        // no decoration
    }
    
    func get(_ key: String) -> TemplateData? {
        let codingPath = key.components(separatedBy: ".")
        return currentContext?.get(at: codingPath)
    }
}
