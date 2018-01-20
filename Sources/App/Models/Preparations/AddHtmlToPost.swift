import FluentProvider
import SwiftSoup

struct AddHtmlToPost: Preparation {
    
    static func prepare(_ database: Database) throws {
        
        try database.modify(Post.self) { modifier in
            modifier.string(Post.htmlContentKey, length: Post.contentSize)
            modifier.string(Post.partOfContentKey, length: Post.partOfContentSize)
        }
        
        try database.modify(Post.self) { _ in
            
            try Post.all().forEach { post in
                post.htmlContent = try HtmlHelper.html(from: post.content) ?? ""
                post.partOfContent = try SwiftSoup.parse(post.htmlContent).text().take(n: Post.partOfContentSize)
                
                try post.save()
            }
        }
    }
    
    static func revert(_ database: Database) throws {
        
        try database.modify(Post.self) { modifier in
            modifier.delete(Post.htmlContentKey)
            modifier.delete(Post.partOfContentKey)
        }
    }
}
