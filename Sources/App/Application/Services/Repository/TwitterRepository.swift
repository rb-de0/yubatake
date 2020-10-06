import Poppo
import Vapor

protocol TwitterRepository {
    func post(_ post: Post, on request: Request) throws
}

final class DefaultTwitterRepository: TwitterRepository {

    private let tweetFormat: String?
    private let hostName: String

    init(applicationConfig: ApplicationConfig) {
        #if os(Linux)
            tweetFormat = applicationConfig.tweetFormat?.replacingOccurrences(of: "$@", with: "$s")
        #else
            tweetFormat = applicationConfig.tweetFormat
        #endif
        hostName = applicationConfig.hostName
    }

    func post(_ post: Post, on request: Request) throws {
        guard let format = tweetFormat else {
            return
        }
        let id = try post.requireID()
        let poppo = try request.auth.require(User.self).makePoppo()
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

struct TwitterRepositoryKey {}

extension TwitterRepositoryKey: StorageKey {
    typealias Value = TwitterRepository
}

extension Application {
    func register(twitterRepository: TwitterRepository) {
        storage[TwitterRepositoryKey.self] = twitterRepository
    }

    var twitterRepository: TwitterRepository {
        guard let twitterRepository = storage[TwitterRepositoryKey.self] else {
            fatalError("service not initialized")
        }
        return twitterRepository
    }
}
