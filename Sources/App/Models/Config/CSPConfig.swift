import Configs

struct CSPConfig {
    
    let styleSources: [String]
    let scriptSources: [String]
    
    init(config: Config) {
        styleSources = config["csp", "styleSources"]?.array?.flatMap { $0.string } ?? []
        scriptSources = config["csp", "scriptSources"]?.array?.flatMap { $0.string } ?? []
    }
    
    func makeConfigirationString() -> String {
        
        let space = " "
        let semicolon = ";"
        
        let defaultSource = ["default-src", "'self'"].joined(separator: space)
        let styleSource = (["style-src","'self'"] + styleSources).joined(separator: space)
        let scriptSource = (["script-src","'self'"] + scriptSources + ["'unsafe-inline'"]).joined(separator: space)
        
        return [defaultSource, styleSource, scriptSource].joined(separator: semicolon)
    }
}
