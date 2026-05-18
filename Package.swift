// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "mnesora",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .library(name: "MnesoraCore", targets: ["MnesoraCore"]),
        .executable(name: "mnesora-cli", targets: ["mnesora-cli"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.1.0"),
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.29.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.4.0"),
    ],
    targets: [
        .target(
            name: "MnesoraCore",
            dependencies: [
                "Yams",
                .product(name: "GRDB", package: "GRDB.swift"),
            ],
            resources: [
                .copy("Resources/Templates"),
            ]
        ),
        .executableTarget(
            name: "mnesora-cli",
            dependencies: [
                "MnesoraCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .testTarget(
            name: "MnesoraCoreTests",
            dependencies: ["MnesoraCore"]
        ),
    ]
)
