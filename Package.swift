// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

//
//  Package.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 07/26/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

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
        .package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.6.1"),
    ],
    targets: [
        .target(
            name: "ForescoopGraph",
            path: "Sources/ForescoopGraph"),
        .target(
            name: "Forescoop",
            dependencies: [
                "ForescoopGraph",
                .product(
                    name: "Lottie",
                    package: "lottie-spm",
                    // Lottie is distributed as a static XCFramework. Xcode's
                    // macOS JIT preview agent crashes while registering its
                    // Swift protocol conformances, even for views that do not
                    // render a Lottie animation. macOS uses the native
                    // fallback declared in LottieWeatherBackground instead.
                    condition: .when(platforms: [.iOS, .tvOS, .visionOS])
                ),
            ],
            path: "Sources/Forescoop",
            resources: [.process("Resources")]),
        .testTarget(
            name: "ForescoopTests",
            dependencies: ["Forescoop"],
            path: "Tests/ForescoopTests"),
    ]
)
