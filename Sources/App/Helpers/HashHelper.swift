import Vapor

final class HashHelper: ApplicationHelper {
    
    static var hash: HashProtocol!
    
    static func setup(_ drop: Droplet) throws {
        hash = drop.hash
    }
}
