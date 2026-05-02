// swift-tools-version: 6.0
import PackageDescription

#if TUIST
import struct ProjectDescription.PackageSettings

let packageSettings = PackageSettings(
    productTypes: [
        "ComposableArchitecture": .staticFramework,
        "Dependencies": .staticFramework,
        "Clocks": .staticFramework,
        "ConcurrencyExtras": .staticFramework,
        "CombineSchedulers": .staticFramework,
        "IdentifiedCollections": .staticFramework,
        "OrderedCollections": .staticFramework
    ]
)
#endif

let package = Package(
    name: "ExternalDependencies",
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            .upToNextMinor(from: "1.25.5")
        ),
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk",
            .upToNextMinor(from: "12.12.1")
        ),
        .package(
            url: "https://github.com/google/GoogleSignIn-iOS",
            .upToNextMinor(from: "9.1.0")
        )
    ]
)
