import Vapor
import HTTP

protocol ViewCreator {
    func make(_ path: String, _ context: NodeRepresentable, for request: Request) throws -> View
}
