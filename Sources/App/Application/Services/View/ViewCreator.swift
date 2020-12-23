import Leaf
import LeafKit
import Vapor

final class ViewCreator {

    let decorators: [ViewDecorator]

    init(decorators: [ViewDecorator]) {
        self.decorators = decorators
    }

    func create(path: String, context: Encodable, siteInfo: SiteInfo, forAdmin: Bool, for request: Request) -> EventLoopFuture<View> {
        var decoratad = context
        decorators.forEach {
            decoratad = $0.decodate(context: decoratad, for: request)
        }
        do {
            let viewData = try LeafDataEncoder().encode(encodable: decoratad)
            if forAdmin {
                return request.leaf
                    .render(path: path, context: viewData)
                    .map { buffer in
                        View(data: buffer)
                    }
            }
            let themeDirectory = request.application.fileConfig.templateDirectory(in: siteInfo.selectedTheme)
            var configuration = LeafConfiguration(rootDirectory: themeDirectory)
            let rootDirectory = configuration.rootDirectory
            let original = request.leaf
            let sources = LeafSources.singleSource(
                NIOLeafFiles(fileio: request.application.fileio,
                             limits: .default,
                             sandboxDirectory: rootDirectory,
                             viewDirectory: rootDirectory))
            let renderer = LeafRenderer(configuration: configuration,
                                        tags: original.tags,
                                        sources: sources,
                                        eventLoop: original.eventLoop,
                                        userInfo: original.userInfo)
            return renderer
                .render(path: path, context: viewData)
                .map { buffer in
                    View(data: buffer)
                }
        } catch {
            return request.eventLoop.makeFailedFuture(error)
        }
    }
}

extension ViewCreator {
    class func `default`() -> ViewCreator {
        return .init(decorators: [MessageDeliveryViewDecorator(), CSRFViewDecorator()])
    }
}

extension ViewCreator: StorageKey {
    typealias Value = ViewCreator
}

extension Application {
    func register(viewCreator: ViewCreator) {
        storage[ViewCreator.self] = viewCreator
    }

    var viewCreator: ViewCreator {
        guard let viewCreator = storage[ViewCreator.self] else {
            fatalError("service not initialized")
        }
        return viewCreator
    }
}
