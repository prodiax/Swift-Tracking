// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Swift-Tracking",
    platforms: [
        .macOS("10.15"),
        .iOS("13.0"),
        .tvOS("13.0"),
        .watchOS("7.0"),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftTracking",
            targets: ["SwiftTracking"]
        )
    ],
    dependencies: [
        // No external dependencies - keeping it minimal
    ],
    targets: [
        .target(
            name: "SwiftTracking",
            dependencies: [],
            path: "Sources/SwiftTracking"
        ),
        .testTarget(
            name: "SwiftTrackingTests",
            dependencies: [
                .target(name: "SwiftTracking"),
            ],
            path: "Tests/SwiftTrackingTests"
        )
    ]
)
