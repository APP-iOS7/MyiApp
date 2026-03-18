import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Domain",
    targets: [
        .target(
            name: "Domain",
            destinations: .iOS,
            product: .framework,
            bundleId: BundleID.domain,
            deploymentTargets: DeploymentTarget.iOS,
            infoPlist: .default,
            sources: ["Sources/**"],
            scripts: [.swiftFormat]
        ),
        .target(
            name: "DomainTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: BundleID.domainTests,
            deploymentTargets: DeploymentTarget.iOS,
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [.target(name: "Domain")]
        )
    ]
)
