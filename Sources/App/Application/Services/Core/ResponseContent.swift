import Vapor

protocol ResponseContent: Content {}

extension ResponseContent {
    init(from _: Decoder) throws { fatalError() }
}
