// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "note",
    products: [
        .executable(name: "Run", targets: ["Run"])
    ],
    dependencies: [
        .package(url: "https://github.com/brokenhandsio/VaporSecurityHeaders.git", from: "2.0.0"),
        .package(url: "https://github.com/rb-de0/CSRF.git", .branch("vapor3")),
        .package(url: "https://github.com/rb-de0/Poppo.git", from: "1.0.0"),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor-community/markdown.git", from: "0.4.0"),
        .package(url: "https://github.com/vapor-community/pagination.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0-rc"),
        .package(url: "https://github.com/vapor/fluent-mysql.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor/redis.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor/validation.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0")
    ],
    targets: [
        .target(name: "App", dependencies: [
            "Authentication",
            "CSRF",
            "FluentMySQL",
            "Leaf",
            "Pagination",
            "Poppo",
            "Redis",
            "SwiftMarkdown",
            "SwiftSoup",
            "Validation",
            "Vapor",
            "VaporSecurityHeaders"
        ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "NoteTests", dependencies: ["App"])
    ]
)
