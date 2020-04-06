import SwiftMarkdown
import SwiftSoup

extension String {
    var htmlFromMarkdown: String? {
        return (try? SwiftSoup.clean(try markdownToHTML(self, options: []), htmlWhiteList())) ?? nil
    }
}

private extension String {
    func htmlWhiteList() throws -> Whitelist {
        return try Whitelist.relaxed()
            .removeProtocols("img", "src", "http", "https")
            .removeProtocols("a", "href", "ftp", "http", "https", "mailto")
            .addAttributes("blockquote", "class", "data-lang")
            .addAttributes("img", "class")
    }
}
