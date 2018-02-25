@testable import App
import Cookies
import Fluent
import HTTP
import Vapor
import XCTest

final class DataMaker {
    
    class func makePost(title: String = "title", content: String = "content", isStatic: Bool = false, categoryId: Int? = nil) throws -> Post {
        return try Post(request: makePostRequest(title: title, content: content, isStatic: isStatic, categoryId: categoryId))
    }
    
    class func makePostRequest(title: String = "title", content: String = "content", isStatic: Bool = false, categoryId: Int? = nil) throws -> Request {
        return makeAuthorizedRequest(json: makePostJSON(title: title, content: content, isStatic: isStatic, categoryId: categoryId))
    }
    
    class func makeTag(_ name: String) throws -> Tag {
        return try Tag(request: makeTagRequest(name))
    }
    
    class func makeTagRequest(_ name: String) throws -> Request {
        return makeAuthorizedRequest(json: makeTagJSON(name: name))
    }
    
    class func makeCategory(_ name: String) throws -> App.Category {
        return try Category(request: makeCategoryRequest(name))
    }
    
    class func makeCategoryRequest(_ name: String) throws -> Request {
        return makeAuthorizedRequest(json: makeCategoryJSON(name: name))
    }
    
    class func makeImage(_ name: String) throws -> (ImageData, Image) {
        let data = try ImageData(request: makeAuthorizedRequest(json: makeImageDataJSON(name: name)))
        return (data, try Image(data: data))
    }
    
    class func makeSiteInfoRequest(name: String, description: String) throws -> Request {
        return makeAuthorizedRequest(json: ["name": .init(name), "description": .init(description)])
    }
    
    class func makePostJSON(title: String = "title", content: String = "content", isStatic: Bool = false, categoryId: Int? = nil) -> JSON {
        return [
            "title": .init(title),
            "content": .init(content),
            "is_publish": true,
            "is_static": .init(isStatic),
            "category": categoryId.map { .init($0) } ?? nil
        ]
    }
    
    class func makeTagJSON(name: String) -> JSON {
        return ["name": .init(name)]
    }
    
    class func makeCategoryJSON(name: String) -> JSON {
        return ["name": .init(name)]
    }
    
    class func makeImageDataJSON(name: String) -> JSON {
        return ["image_file_name": .init(name), "image_file_data": ""]
    }
    
    class func makeImageJSON(path: String) -> JSON {
        return ["path": .init(path), "alt_description": ""]
    }
    
    private class func makeAuthorizedRequest(json: JSON) -> Request {
        let request = Request(method: .get, uri: "")
        request.json = json
        request.auth.authenticate(try! User.all().first!)
        return request
    }
}
