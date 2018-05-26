import Vapor

extension Optional where Wrapped: FutureType {
    
    func form(on eventLoop: EventLoop) -> Future<Wrapped.Expectation?> {
        
        let promise = eventLoop.newPromise(Optional<Wrapped.Expectation>.self)
        
        if let future = self {
            future.addAwaiter { result in
                switch result {
                case .error(let error):
                    promise.fail(error: error)
                case .success(let expectation):
                    promise.succeed(result: expectation)
                }
            }
        } else {
            promise.succeed(result: nil)
        }
        
        return promise.futureResult
    }
}
