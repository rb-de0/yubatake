import HTTP

protocol TwitterRepository {
    func tweetNewPost(_ post: Post, from user: User, on request: Request) throws
}
