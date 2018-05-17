import Vapor

struct SiteInfoForm: Form, Content {
    let name: String
    let description: String
}
