import Vapor

protocol ViewDecorator {
    func decodate(context: Encodable, for request: Request) -> Encodable
}
