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
        .package(url: "https://github.com/vapor-community/markdown-provider.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/vapor-community/CSRF.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/brokenhandsio/VaporSecurityHeaders.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/tid-kijyun/Kanna.git", .upToNextMajor(from: "2.0.0"))
    ],
    targets: [
        .target(name: "App", dependencies: [
            "Vapor",
            "FluentProvider",
            "LeafProvider",
            "ValidationProvider",
            "AuthProvider",
            "MarkdownProvider",
            "CSRF",
            "VaporSecurityHeaders",
            "Kanna"
        ]),
        .target(name: "Run", dependencies: ["App"])
    ]
)
