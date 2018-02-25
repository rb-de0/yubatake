import CSRF
import Vapor

extension CSRF {
    
    struct CSRFViewDecorator: ViewDecorator {

        func decorate(node: inout Node, with request: Request) throws {
            try node.set("csrf_token", try CSRF().createToken(from: request))
        }
    }
    
    init(config: Config, tokenRetrieval: TokenRetrievalHandler) {
        config.addViewDecorator(CSRFViewDecorator())
        self.init(tokenRetrieval: tokenRetrieval)
    }
}
