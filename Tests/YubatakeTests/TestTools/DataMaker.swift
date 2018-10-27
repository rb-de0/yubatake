@testable import App
import Vapor
import XCTest

final class DataMaker {
    
    // MARK: - Post
    
    struct TestPostForm: Content {
        
        private enum CodingKeys: String, CodingKey {
            case title
            case content
            case category
            case tags
            case isStatic = "is_static"
            case isPublished = "is_published"
        }
        
        let title: String
        let content: String
        let category: Int?
        let tags: String
        let isStatic: String?
        let isPublished: String?
    }
    
    class func makePost(title: String = "title",
                        content: String = "content",
                        categoryId: Int? = nil,
                        isStatic: Bool = false,
                        isPublished: Bool = true,
                        on container: Container,
                        conn: DatabaseConnectable) throws -> Post {
        
        let form = try makePostForm(title: title, content: content, categoryId: categoryId, isStatic: isStatic, isPublished: isPublished)
        return try Post(from: form, on: try makeAuthorizedRequest(on: container, conn: conn))
    }
    
    class func makePostForm(title: String,
                        content: String,
                        categoryId: Int?,
                        isStatic: Bool,
                        isPublished: Bool) throws -> PostForm {
        
        let json: [String: Any?] = ["title": title, "content": content, "category": categoryId, "tags": "", "is_static": isStatic, "is_published": isPublished]
        return try decode(PostForm.self, from: json)
    }
    
    class func makePostFormForTest(title: String,
                        content: String,
                        categoryId: Int? = nil,
                        tags: String,
                        isStatic: Bool = false,
                        isPublished: Bool = true) throws -> TestPostForm {
        
        return TestPostForm(title: title, content: content, category: categoryId, tags: tags, isStatic: isStatic ? "on" : nil, isPublished: isPublished ? "on" : nil)
    }
    
    // MARK: - Category
    
    class func makeCategory(_ name: String) throws -> App.Category {
        return try Category(from: CategoryForm(name: name))
    }
    
    class func makeCategoryFormForTest(_ name: String) -> [String: String] {
        return ["name": name]
    }
    
    // MARK: - Tag
    
    class func makeTag(_ name: String) throws -> Tag {
        return try Tag(from: TagForm(name: name))
    }
    
    class func makeTagFormForTest(_ name: String) -> [String: String] {
        return ["name": name]
    }
    
    // MARK: - Image
    
    class func makeImage(_ name: String, on container: Container) throws -> (ImageUploadForm, Image){
        let form = try decode(ImageUploadForm.self, from: ["image_file_data": "data", "image_file_name": name])
        let image = try Image(from: name, on: container)
        return (form, image)
    }
    
    class func makeImageFormForTest(name: String, altDescription: String) -> [String: String] {
        return ["name": name, "alt_description": altDescription]
    }

    // MARK: - Util
    
    class func makeAuthorizedRequest(on container: Container, conn: DatabaseConnectable) throws -> Request {
        let request = Request(http: HTTPRequest(method: .GET, url: "/"), using: container)
        let user = try User.find(1, on: conn).unwrap(or: TestError.unexpected).wait()
        try request.authenticate(user)
        return request
    }
}

extension DataMaker {
    
    class func decode<T: Decodable>(_ type: T.Type, from json: [String: Any?]) throws -> T {
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        return try JSONDecoder().decode(T.self, from: jsonData)
    }
}
