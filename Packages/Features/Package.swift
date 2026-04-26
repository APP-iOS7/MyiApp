// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Features",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AppFeature",
            targets: ["AppFeature"]
        ),
        .library(
            name: "AuthFeature",
            targets: ["AuthFeature"]
        )
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(path: "../Clients"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "AppFeature",
            dependencies: [
                "AuthFeature",
                .product(name: "Domain", package: "Domain"),
                .product(name: "Clients", package: "Clients"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "AuthFeature",
            dependencies: [
                .product(name: "Domain", package: "Domain"),
                .product(name: "Clients", package: "Clients"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .testTarget(
            name: "AppFeatureTests",
            dependencies: ["AppFeature"]
        ),
        .testTarget(
            name: "AuthFeatureTests",
            dependencies: ["AuthFeature"]
        )
    ],
    swiftLanguageModes: [.v6]
)
