import Vapor

struct CategoryForm: Form, Content {
    let name: String
}
