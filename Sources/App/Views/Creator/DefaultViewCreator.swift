import Vapor

final class DefaultViewCreator: ViewCreator {
    
    private let renderer: ViewRenderer
    private var decorators = [ViewDecorator]()
    
    init(renderer: ViewRenderer) {
        self.renderer = renderer
    }
    
    func set(_ decorators: [ViewDecorator]) {
        self.decorators = decorators
    }
    
    func make(_ path: String, _ context: NodeRepresentable, for request: Request) throws -> View {
        var node = try context.makeNode(in: ViewContext.shared)
        try decorators.forEach { decorator in
            try decorator.decorate(node: &node, with: request)
        }
        return try renderer.make(path, node, for: request)
    }
}
