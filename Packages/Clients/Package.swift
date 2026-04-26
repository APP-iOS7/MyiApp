// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Clients",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "Clients",
            targets: ["Clients"]
        )
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.0.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "12.0.0"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "9.0.0")
    ],
    targets: [
        .target(
            name: "Clients",
            dependencies: [
                .product(name: "Domain", package: "Domain"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                .product(name: "GoogleSignInSwift", package: "GoogleSignIn-iOS")
            ]
        ),
        .testTarget(
            name: "ClientsTests",
            dependencies: ["Clients"]
        )
    ],
    swiftLanguageModes: [.v6]
)
