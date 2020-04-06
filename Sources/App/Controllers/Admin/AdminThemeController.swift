import Vapor

final class AdminThemeController {
    private struct ContextMaker {
        static func makeCreateView() -> AdminViewContext {
            return AdminViewContext(path: "themes", menuType: .themes)
        }
    }

    func index(request: Request) throws -> EventLoopFuture<View> {
        return try ContextMaker.makeCreateView().makeResponse(for: request)
    }
}
