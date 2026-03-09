// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        productTypes: [:]
    )
#endif

let package = Package(
    name: "MyiApp",
    dependencies: [
        // .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.0.0"),
    ]
)
