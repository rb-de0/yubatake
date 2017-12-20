// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "note",
    products: [
        .executable(name: "Run", targets: ["Run"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/vapor/fluent-provider.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/vapor/leaf-provider.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/vapor/validation-provider.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/vapor/auth-provider.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/vapor/mysql-provider.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/vapor/redis-provider.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/vapor-community/markdown-provider.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/vapor-community/CSRF.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/brokenhandsio/VaporSecurityHeaders.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/tid-kijyun/Kanna.git", .branch("feature/v4.0.0")),
        .package(url: "https://github.com/rb-de0/Poppo.git", .upToNextMajor(from: "0.4.0"))
    ],
    targets: [
        .target(name: "App", dependencies: [
            "Vapor",
            "FluentProvider",
            "LeafProvider",
            "ValidationProvider",
            "AuthProvider",
            "MarkdownProvider",
            "MySQLProvider",
            "RedisProvider",
            "CSRF",
            "VaporSecurityHeaders",
            "Kanna",
            "Poppo"
        ]),
        .target(name: "Run", dependencies: ["App"])
    ]
)
