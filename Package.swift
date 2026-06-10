// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FNVHash",
    platforms: [ .macOS(.v15), .iOS(.v18), .tvOS(.v15), .watchOS(.v8), .macCatalyst(.v15), .visionOS(.v1) ],
    products: [
        .executable(name: "fnv", targets: ["fnv"]),
        .library(name: "FNVHash", targets: ["FNVHash"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "FNVHash",
            dependencies: []
        ),
        .target(
            name: "Utilities",
            dependencies: []
        ),
        .executableTarget(
            name: "fnv",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "FNVHash",
                "Utilities"
            ]
        ),
        .testTarget(
            name: "FNVHashTests",
            dependencies: ["FNVHash", "Utilities"]
        ),
    ]
)
