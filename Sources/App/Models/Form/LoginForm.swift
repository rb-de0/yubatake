import Vapor

struct LoginForm: Content {
    let name: String
    let password: String
}
