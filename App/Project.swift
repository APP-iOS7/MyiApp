import ProjectDescription

let project = Project(
    name: "MyiApp",
    targets: [
        .target(
            name: "MyiApp",
            destinations: .iOS,
            product: .app,
            bundleId: "com.myiapp.MyiApp",
            infoPlist: .extendingDefault(with: [:]),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .project(target: "AuthFeature", path: "../Features/AuthFeature"),
                .project(target: "HomeFeature", path: "../Features/HomeFeature"),
                .project(target: "DesignSystem", path: "../DesignSystem"),
                .project(target: "Core", path: "../Core"),
            ]
        ),
        .target(
            name: "MyiAppTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.myiapp.MyiAppTests",
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [.target(name: "MyiApp")]
        ),
    ]
)
