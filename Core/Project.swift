import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Core",
    targets: [
        .target(
            name: "Core",
            destinations: .iOS,
            product: .framework,
            bundleId: BundleID.core,
            deploymentTargets: DeploymentTarget.iOS,
            infoPlist: .default,
            sources: ["Sources/**"],
            scripts: [.swiftFormat],
            dependencies: [
                .project(target: "Domain", path: "../Domain"),
                .external(name: "FirebaseAuth")
            ]
        ),
        .target(
            name: "CoreTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "\(BundleID.core).Tests",
            deploymentTargets: DeploymentTarget.iOS,
            infoPlist: .default,
            sources: ["Tests/**/*.swift"],
            dependencies: [
                    .target(name: "Core"),
                    .external(name: "FirebaseCore")
                ]
        )
    ],
    schemes: [
        .scheme(
            name: "Core",
            shared: true,
            buildAction: .buildAction(targets: ["Core"]),
            testAction: .targets(["CoreTests"]),
            runAction: .runAction(executable: "Core")
        )
    ]
)
