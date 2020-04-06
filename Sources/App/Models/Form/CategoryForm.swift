import Vapor

struct CategoryForm: Form, Content {
    let name: String
}

extension CategoryForm: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: .count(1 ... Category.nameLength))
    }
}
