import FluentProvider
import LeafProvider
import MarkdownProvider
import VaporSecurityHeaders

extension Config {
    public func setup() throws {
        
        Node.fuzzy = [Row.self, JSON.self, Node.self]

        try setupProviders()
        try setupConfigurable()
        try setupPreparations()
    }
    
    private func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
        try addProvider(LeafProvider.Provider.self)
        try addProvider(MarkdownProvider.Provider.self)
    }
    
    private func setupConfigurable() throws {
        let config = CSPConfig(config: self)
        let securityHeadersFactory = SecurityHeadersFactory()
        let cspConfig = ContentSecurityPolicyConfiguration(value: config.makeConfigirationString())
        securityHeadersFactory.with(contentSecurityPolicy: cspConfig)
        addConfigurable(middleware: securityHeadersFactory.builder(), name: "security-headers")
    }
    
    private func setupPreparations() throws {
        preparations = [
            Post.self,
            Category.self,
            Tag.self,
            User.self,
            SiteInfo.self,
            Pivot<Post, Tag>.self
        ]
    }
}
