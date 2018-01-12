import SwiftMarkdown
import SwiftSoup
import Vapor

final class HtmlHelper: ApplicationHelper {
    
    static func setup(_ drop: Droplet) throws {}
    
    private class func htmlWhiteList() throws -> Whitelist {
        return try Whitelist.relaxed()
            .removeProtocols("img", "src", "http", "https")
            .removeProtocols("a", "href", "ftp", "http", "https", "mailto")
    }
    
    class func html(from markdown: String) throws -> String? {
        return try SwiftSoup.clean(try markdownToHTML(markdown, options: []), htmlWhiteList())
    }
}
