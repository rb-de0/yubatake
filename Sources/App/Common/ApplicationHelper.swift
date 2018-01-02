import Vapor

protocol ApplicationHelper {
    
    static func setup(_ drop: Droplet) throws
}
