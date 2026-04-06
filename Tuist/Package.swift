// swift-tools-version: 6.1
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings()
#endif

let package = Package(
    name: "MyiApp",
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: .init(1, 25, 5)),
    ]
)
