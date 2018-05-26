import Poppo
import Vapor

protocol TwitterRepository {
    func post(_ post: Post, on request: Request) throws
}

final class TwitterRepositoryDefault: TwitterRepository, Service {
    
    private let tweetFormat: String?
    private let hostName: String
    
    init(applicationConfig: ApplicationConfig) throws {
        
        #if os(Linux)
        self.tweetFormat = applicationConfig.tweetFormat?.replacingOccurrences(of: "$@", with: "$s")
        #else
        self.tweetFormat = applicationConfig.tweetFormat
        #endif
        
        self.hostName = applicationConfig.hostName
    }
    
    func post(_ post: Post, on request: Request) throws {
        
        guard let format = tweetFormat else {
            return
        }
        
        let id = try post.requireID()
        let poppo = try request.requireAuthenticated(User.self).makePoppo()
        let url = "\(hostName)/\(id)"
        
        #if os(Linux)
        post.title.withCString { title in
            url.withCString { url in
                let message = String(format: format, title, url)
                poppo.tweet(status: message)
            }
        }
        #else
        let message = String(format: format, post.title, url)
        poppo.tweet(status: message)
        #endif
    }
}
