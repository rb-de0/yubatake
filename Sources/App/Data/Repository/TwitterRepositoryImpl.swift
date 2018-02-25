import Vapor
import Foundation

final class TwitterRepositoryImpl: TwitterRepository {
    
    private let messageFormat: String
    private let hostName: String
    
    init() {
        
        let config = Configs.resolve(ApplicationConfig.self)
        
        #if os(Linux)
        self.messageFormat = config.messageFormat.replacingOccurrences(of: "$@", with: "$s")
        #else
        self.messageFormat = config.messageFormat
        #endif
        
        self.hostName = config.hostName
    }
    
    func tweetNewPost(_ post: Post, from user: User, on request: Request) throws {
        
        let id = try post.assertId()
        
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
