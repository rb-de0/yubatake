import Vapor
import HTTP

protocol ViewDecorator {
    func decorate(node: inout Node, with request: Request) throws
}

extension Config {
    
    var viewDecorators: [ViewDecorator] {
        get {
            return (storage["view-decorators"] as? [ViewDecorator]) ?? []
        }
        set {
            storage["view-decorators"] = newValue
        }
    }
    
    func addViewDecorator(_ viewDecorator: ViewDecorator) {
        viewDecorators = viewDecorators + [viewDecorator]
    }
}
