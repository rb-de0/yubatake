import Vapor
import Foundation

final class TwitterHelper: ApplicationHelper {
    
    private static var messageFormat: String!
    private static var hostName: String!
    
    static func setup(_ drop: Droplet) throws {
        
        guard let messageFormat = drop.config["twitter", "messageFormat"]?.string,
            let hostName = drop.config["twitter", "hostname"]?.string else {
                
            fatalError("Not found twitter.json or necessary key.")
        }
        
        #if os(Linux)
        self.messageFormat = messageFormat.replacingOccurrences(of: "$@", with: "$s")
        #else
        self.messageFormat = messageFormat
        #endif
        
        self.hostName = hostName
    }
    
    static func tweetNewPost(_ post: Post, from user: User, on request: Request) throws {
        
        guard let id = post.id?.int else {
            throw Abort.serverError
        }
        
        guard let hostName = hostName else {
            throw Abort.serverError
        }
        
        let poppo = user.makePoppo()
        let url = "\(request.uri.scheme)://\(hostName)/\(id)"

        #if os(Linux)
        post.title.withCString { title in
            url.withCString { url in
                let message = String(format: messageFormat, title, url)
                poppo.tweet(status: message)
            }
        }
        #else
        let message = String(format: messageFormat, post.title, url)
        poppo.tweet(status: message)
        #endif
    }
}
