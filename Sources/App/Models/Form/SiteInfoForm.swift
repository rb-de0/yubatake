import Vapor

struct SiteInfoForm: Form, Content {
    let name: String
    let description: String
}

extension SiteInfoForm: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: .count(1 ... SiteInfo.nameLength))
        validations.add("description", as: String.self, is: .count(1 ... SiteInfo.descriptionLength))
    }
}
