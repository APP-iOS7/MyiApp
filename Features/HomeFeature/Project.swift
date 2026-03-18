import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "HomeFeature",
    targets: [
        .target(
            name: "HomeFeatureInterface",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.myiapp.HomeFeatureInterface",
            infoPlist: .default,
            sources: ["Sources/HomeFeatureInterface/**"],
            scripts: [.swiftFormat],
            dependencies: [.project(target: "Domain", path: "../../Domain")]
        ),
        .target(
            name: "HomeFeature",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.myiapp.HomeFeature",
            infoPlist: .default,
            sources: ["Sources/HomeFeature/**"],
            dependencies: [
                .target(name: "HomeFeatureInterface"),
                .project(target: "DesignSystem", path: "../../DesignSystem")
            ]
        )
    ]
)
