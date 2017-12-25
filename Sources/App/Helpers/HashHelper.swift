import Vapor

final class HashHelper: ApplicationHelper {
    
    static var hash: HashProtocol!
    
    static func setup(_ drop: Droplet) {
        hash = drop.hash
    }
}
