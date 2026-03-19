// swift-tools-version: 6.1
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        productTypes: [
            "FirebaseAuth": .framework,
            "FirebaseCore": .framework
        ]
    )
#endif

let package = Package(
    name: "MyiApp",
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "11.0.0"))
    ]
)
