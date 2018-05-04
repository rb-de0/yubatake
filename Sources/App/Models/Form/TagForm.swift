import Vapor

struct TagForm: Form, Content {
    let name: String
}
