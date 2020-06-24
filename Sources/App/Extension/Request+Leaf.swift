import Leaf
import Vapor

extension Request {
    var leaf: LeafRenderer {
        var userInfo = application.leaf.userInfo
        userInfo["request"] = self
        userInfo["application"] = application

        return .init(
            configuration: application.leaf.configuration,
            tags: application.leaf.tags,
            cache: application.leaf.cache,
            sources: application.leaf.sources,
            eventLoop: eventLoop,
            userInfo: userInfo
        )
    }
}
