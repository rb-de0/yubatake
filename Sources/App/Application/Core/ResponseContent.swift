import Vapor

protocol ResponseContent: Content {}

extension ResponseContent {
    init(from decoder: Decoder) throws { fatalError() }
}
