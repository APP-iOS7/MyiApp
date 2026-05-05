// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ExternalDependencies",
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            .upToNextMinor(from: "1.25.5")
        ),
        .package(
            url: "https://github.com/google/GoogleSignIn-iOS",
            .upToNextMinor(from: "9.1.0")
        )
    ]
)
