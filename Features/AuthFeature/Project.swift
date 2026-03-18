import ProjectDescription

let project = Project(
    name: "AuthFeature",
    targets: [
        .target(
            name: "AuthFeatureInterface",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.myiapp.AuthFeatureInterface",
            infoPlist: .default,
            sources: ["Sources/AuthFeatureInterface/**"],
            dependencies: [.project(target: "Domain", path: "../../Domain")]
        ),
        .target(
            name: "AuthFeature",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.myiapp.AuthFeature",
            infoPlist: .default,
            sources: ["Sources/AuthFeature/**"],
            dependencies: [
                .target(name: "AuthFeatureInterface"),
                .project(target: "DesignSystem", path: "../../DesignSystem")
            ]
        )
    ]
)
