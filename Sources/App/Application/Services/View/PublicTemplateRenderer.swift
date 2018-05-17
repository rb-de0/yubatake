import Leaf
import Vapor

final class PublicTemplateRenderer: TemplateRenderer {
    
    private let base: TemplateRenderer
    private(set) var relativeDirectory: String
    
    init(base: TemplateRenderer, relativeDirectory: String) {
        self.base = base
        self.relativeDirectory = relativeDirectory
    }
    
    func updateDirectory(to directory: String) {
        self.relativeDirectory = directory
    }
    
    // bridge
    var tags: [String : TagRenderer] { return base.tags }
    var container: Container { return base.container }
    var parser: TemplateParser { return base.parser }
    var astCache: ASTCache? {
        get { return base.astCache }
        set { base.astCache = newValue }
    }
    var templateFileEnding: String { return base.templateFileEnding }
}
