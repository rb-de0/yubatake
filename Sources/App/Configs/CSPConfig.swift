import Configs

struct CSPConfig: ConfigInitializable {
    
    struct Value {
        let key: String
        let values: [String]
    }
    
    let values: [Value]
    
    init(config: Config) throws {
        
        if let array = config["csp"]?.array {
            values = array.flatMap { settings -> Value? in
                guard let key = settings["key"]?.string,
                    let values = settings["values"]?.array?.flatMap ({ $0.string }) else {
                    return nil
                }
                return Value(key: key, values: values)
            }
        } else {
            values = []
        }
    }
    
    func makeConfigirationString() -> String {
        
        let space = " "
        let semicolon = ";"
        
        return values
            .map {([$0.key, "'self'"] + $0.values).joined(separator: space)}
            .joined(separator: semicolon)
    }
}
