import Vapor
import Foundation

final class TwitterHelper: ApplicationHelper {
    
    private static var messageFormat: String!
    
    static func setup(_ drop: Droplet) {
        
        guard let messageFormat = drop.config["twitter", "messageFormat"]?.string else {
            fatalError("Not found twitter.json or messageFormat key.")
        }
        
        self.messageFormat = messageFormat
    }
    
    static func tweetNewPost(_ post: Post, from user: User, on request: Request) throws {
        
        guard let id = post.id?.int else {
            throw Abort.serverError
        }
        
        let poppo = user.makePoppo()
        let url = "\(request.uri.scheme)://\(request.uri.hostname)/\(id)"

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
