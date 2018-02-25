import Configs
import Vapor

struct ApplicationConfig: ConfigInitializable {
    
    let messageFormat: String
    let hostName: String
    let dateFormat: String
    let meta: Meta?
    
    struct Meta: JSONRepresentable {
        let pageDescription: String
        let pageImage: String
        let twitter: TwitterMeta?
        
        init?(config: [String: Config]) {
            
            guard let pageDescription = config["page_description"]?.string,
                let pageImage = config["page_image"]?.string else {
                
                return nil
            }
            
            self.pageDescription = pageDescription
            self.pageImage = pageImage
            self.twitter = config["twitter"]?.object.flatMap { TwitterMeta(config: $0) }
        }
        
        func makeJSON() throws -> JSON {
            var json = JSON()
            try json.set("page_description", pageDescription)
            try json.set("page_image", pageImage)
            try json.set("twitter", twitter?.makeJSON())
            return json
        }
    }
    
    struct TwitterMeta: JSONRepresentable {
        let imageAlt: String
        let username: String
        
        init?(config: [String: Config]) {
            
            guard let imageAlt = config["image_alt"]?.string,
                let username = config["username"]?.string else {
                
                return nil
            }
            
            self.imageAlt = imageAlt
            self.username = username
        }
        
        func makeJSON() throws -> JSON {
            var json = JSON()
            try json.set("image_alt", imageAlt)
            try json.set("username", username)
            return json
        }
    }
    
    init(config: Config) throws {
        
        guard let messageFormat = config["note", "tweetFormat"]?.string,
            let hostName = config["note", "hostname"]?.string,
            let dateFormat = config["note", "dateFormat"]?.string else {
                
            self.messageFormat = ""
            self.hostName = ""
            self.dateFormat = ""
            self.meta = nil
            return
        }
        
        self.messageFormat = messageFormat
        self.hostName = hostName
        self.dateFormat = dateFormat
        self.meta = Meta(config: config["note", "meta"]?.object ?? [:])
    }
}
