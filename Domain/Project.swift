import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Domain",
    targets: [
        .target(
            name: "Domain",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: BundleID.domain,
            deploymentTargets: DeploymentTarget.iOS,
            infoPlist: .default,
            sources: ["Sources/**"],
            scripts: [.swiftFormat]
        ),
        .target(
            name: "DomainTesting",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: BundleID.domain + ".testing",
            deploymentTargets: DeploymentTarget.iOS,
            infoPlist: .default,
            sources: ["Testing/**"],
            scripts: [.swiftFormat],
            dependencies: [.target(name: "Domain")]
        ),
        .target(
            name: "DomainTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: BundleID.domainTests,
            deploymentTargets: DeploymentTarget.iOS,
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "Domain"),
                .target(name: "DomainTesting")
            ]
        )
    ]
)
