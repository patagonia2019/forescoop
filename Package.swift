// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ForescoopPackage",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
        .tvOS(.v26),
        .visionOS(.v26),
        .watchOS(.v26)
    ], products: [
        .library(
            name: "Forescoop",
            targets: ["Forescoop"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Forescoop",
            dependencies: [],
            path: "Sources/Forescoop",
            resources: [.process("Resources")]),
        .testTarget(
            name: "ForescoopTests",
            dependencies: ["Forescoop"],
            path: "Tests/ForescoopTests"),
    ]
)
