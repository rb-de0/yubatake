import FluentProvider
import LeafProvider
import MarkdownProvider

extension Config {
    public func setup() throws {
        
        Node.fuzzy = [Row.self, JSON.self, Node.self]

        try setupProviders()
        try setupPreparations()
    }
    
    private func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
        try addProvider(LeafProvider.Provider.self)
        try addProvider(MarkdownProvider.Provider.self)
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
