@testable import App

final class TestViewRenderer: ViewRenderer {
    
    var shouldCache: Bool = false
    
    private(set) var context: Node?
    
    func make(_ path: String, _ node: Node) throws -> View {
        context = node
        return View(data: "".bytes)
    }
    
    func get<T>(_ path: String) -> T? {
        return (try? context?.get(path)) ?? nil
    }
}
