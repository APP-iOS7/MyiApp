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
            dependencies: [.project(target: "Domain", path: "../Domain")]
        )
    ]
)
