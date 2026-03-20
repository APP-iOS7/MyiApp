// swift-tools-version: 6.1
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        productTypes: [
            "FirebaseAuth": .framework,
            "FirebaseCore": .framework,
            "FirebaseFirestore": .staticFramework,
            "ComposableArchitecture": .framework
        ]
    )
#endif

let package = Package(
    name: "MyiApp",
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "11.0.0")),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.17.1"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS.git", from: "8.0.0")
    ]
)
