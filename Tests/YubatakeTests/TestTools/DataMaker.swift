@testable import App
import Vapor

final class DataMaker {}

extension DataMaker {
    class func makeCategory(name: String) -> App.Category {
        return Category(name: name)
    }
}

extension App.Category {
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

extension DataMaker {
    class func makeTag(name: String) -> Tag {
        return Tag(name: name)
    }
}

extension Image {
    convenience init(path: String, altDescription: String) {
        self.init()
        self.path = path
        self.altDescription = altDescription
    }
}

extension DataMaker {
    class func makeImage(path: String, altDescription: String) -> Image {
        return Image(path: path, altDescription: altDescription)
    }
}

extension Post {
    convenience init(title: String,
                     content: String,
                     htmlContent: String,
                     partOfContent: String,
                     categoryId: Int?,
                     userId: Int?,
                     isStatic: Bool,
                     isPublished: Bool) {
        self.init()
        self.title = title
        self.content = content
        self.htmlContent = htmlContent
        self.partOfContent = partOfContent
        self.$category.id = categoryId
        self.$user.id = userId
        self.isStatic = isStatic
        self.isPublished = isPublished
    }
}

extension DataMaker {
    class func makePost(title: String,
                        content: String,
                        htmlContent: String,
                        partOfContent: String,
                        categoryId: Int? = nil,
                        userId: Int?,
                        isStatic: Bool = false,
                        isPublished: Bool = true) -> Post {
        return Post(title: title,
                    content: content,
                    htmlContent: htmlContent,
                    partOfContent: partOfContent,
                    categoryId: categoryId,
                    userId: userId,
                    isStatic: isStatic,
                    isPublished: isPublished)
    }
}
