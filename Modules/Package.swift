// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyIModules",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "Domain", targets: ["Domain"]),
        .library(name: "Clients", targets: ["Clients"]),
        .library(name: "AppFeature", targets: ["AppFeature"]),
        .library(name: "AuthFeature", targets: ["AuthFeature"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.0.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "12.0.0"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "9.0.0")
    ],
    targets: [
        .target(
            name: "Domain",
            path: "Sources/Domain"
        ),
        .target(
            name: "Clients",
            dependencies: [
                .target(name: "Domain"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                .product(name: "GoogleSignInSwift", package: "GoogleSignIn-iOS")
            ],
            path: "Sources/Clients"
        ),
        .target(
            name: "AppFeature",
            dependencies: [
                .target(name: "AuthFeature"),
                .target(name: "Domain"),
                .target(name: "Clients"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Features/AppFeature"
        ),
        .target(
            name: "AuthFeature",
            dependencies: [
                .target(name: "Domain"),
                .target(name: "Clients"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Features/AuthFeature"
        ),
        .testTarget(
            name: "DomainTests",
            dependencies: [.target(name: "Domain")],
            path: "Tests/DomainTests"
        ),
        .testTarget(
            name: "ClientsTests",
            dependencies: [.target(name: "Clients")],
            path: "Tests/ClientsTests"
        ),
        .testTarget(
            name: "AppFeatureTests",
            dependencies: [.target(name: "AppFeature")],
            path: "Tests/Features/AppFeatureTests"
        ),
        .testTarget(
            name: "AuthFeatureTests",
            dependencies: [.target(name: "AuthFeature")],
            path: "Tests/Features/AuthFeatureTests"
        )
    ],
    swiftLanguageModes: [.v6]
)
