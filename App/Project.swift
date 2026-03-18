import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "MyiApp",
    targets: [
        .target(
            name: "MyiApp",
            destinations: .iOS,
            product: .app,
            bundleId: BundleID.app,
            deploymentTargets: DeploymentTarget.iOS,
            infoPlist: .app,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            entitlements: .file(path: "MyiApp.entitlements"),
            scripts: [.swiftFormat],
            dependencies: [
                .project(target: "AuthFeature", path: "../Features/AuthFeature"),
                .project(target: "HomeFeature", path: "../Features/HomeFeature"),
                .project(target: "DesignSystem", path: "../DesignSystem"),
                .project(target: "Core", path: "../Core")
            ],
            settings: .app
        ),
        .target(
            name: "MyiAppTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: BundleID.appTests,
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [.target(name: "MyiApp")]
        )
    ]
)
