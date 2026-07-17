// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FNVHash",
    platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v15), .watchOS(.v8), .macCatalyst(.v15), .visionOS(.v1)],
    products: [
        .executable(name: "fnv", targets: ["fnv"]),
        .library(name: "FNVHash", targets: ["FNVHash"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
    ],
    targets: [
        .target(name: "FNVHash"),
        .target(name: "Utilities"),
        .target(
            name: "FNVCLI",
            dependencies: ["FNVHash", "Utilities"]
        ),
        .executableTarget(
            name: "fnv",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "FNVCLI",
            ]
        ),
        .executableTarget(
            name: "FNVHashBenchmarks",
            dependencies: ["FNVHash"],
            path: "Benchmarks/FNVHashBenchmarks"
        ),
        .testTarget(
            name: "FNVHashTests",
            dependencies: ["FNVHash", "Utilities"]
        ),
        .testTarget(
            name: "FNVCLITests",
            dependencies: ["FNVCLI", "Utilities"]
        ),
    ]
)
