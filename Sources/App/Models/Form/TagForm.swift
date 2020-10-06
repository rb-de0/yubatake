import Vapor

struct TagForm: Form, Content {
    let name: String
}

extension TagForm: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: .count(1 ... Tag.nameLength))
    }
}
