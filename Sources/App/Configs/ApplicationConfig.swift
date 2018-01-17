import Configs

struct ApplicationConfig {
    
    let messageFormat: String
    let hostName: String
    let dateFormat: String
    
    init(config: Config) {
        
        guard let messageFormat = config["note", "tweetFormat"]?.string,
            let hostName = config["note", "hostname"]?.string,
            let dateFormat = config["note", "dateFormat"]?.string else {
                
            fatalError("Not found note.json or necessary key.")
        }
        
        self.messageFormat = messageFormat
        self.hostName = hostName
        self.dateFormat = dateFormat
    }
}
