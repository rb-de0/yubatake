// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "yubatake",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "Run", targets: ["Run"])
    ],
    dependencies: [
        .package(url: "https://github.com/rb-de0/Poppo.git", from: "1.0.0"),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "1.0.0"),
        .package(name: "SwiftMarkdown", url: "https://github.com/vapor-community/markdown.git", from: "0.6.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0-rc"),
        .package(url: "https://github.com/vapor/redis.git", from: "4.0.0-beta"),
        .package(url: "https://github.com/vapor/fluent-mysql-driver.git", from: "4.0.0-rc"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-rc"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-rc"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0")
    ],
    targets: [
        .target(name: "App", dependencies: [
            .product(name: "Fluent", package: "fluent"),
            .product(name: "FluentMySQLDriver", package: "fluent-mysql-driver"),
            .product(name: "Vapor", package: "vapor"),
            .product(name: "Leaf", package: "leaf"),
            .product(name: "Redis", package: "redis"),
            .product(name: "Poppo", package: "Poppo"),
            .product(name: "SwiftSoup", package: "SwiftSoup"),
            .product(name: "SwiftyJSON", package: "SwiftyJSON"),
            .byName(name: "SwiftMarkdown")
        ]),
        .target(name: "Run", dependencies: [
            .target(name: "App")
        ]),
        .testTarget(name: "YubatakeTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor")
        ])
    ]
)
