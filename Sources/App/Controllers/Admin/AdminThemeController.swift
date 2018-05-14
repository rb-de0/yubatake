import Vapor

final class AdminThemeController {
    
    private struct ContextMaker {
        
        static func makeCreateView() -> AdminViewContext {
            return AdminViewContext(path: "themes", menuType: .themes)
        }
    }
    
    func index(request: Request) throws -> Future<View> {
        return try ContextMaker.makeCreateView().makeResponse(for: request)
    }
}
