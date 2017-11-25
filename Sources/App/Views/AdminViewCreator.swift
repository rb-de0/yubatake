import Vapor

final class AdminViewCreator {
    
    private static var viewRenderer: ViewRenderer!
    
    class func setUp(viewRenderer: ViewRenderer) {
        self.viewRenderer = viewRenderer
    }
    
    class func create(_ path: String, context: NodeRepresentable = Node(ViewContext.shared), for request: Request) throws -> View {
        return try viewRenderer.make(path, context, for: request)
    }
}
