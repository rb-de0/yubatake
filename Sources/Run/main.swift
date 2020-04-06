import App
import Vapor

do {
    var env = try Environment.detect()
    try LoggingSystem.bootstrap(from: &env)

    let app = Application(env)
    defer { app.shutdown() }

    try configure(app)
    try app.run()
} catch {
    print(error)
    exit(1)
}
