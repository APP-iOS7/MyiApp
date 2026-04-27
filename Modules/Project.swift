import ProjectDescription

private let bundleIdPrefix = "kr.co.codegrove"
private let deployment: DeploymentTargets = .iOS("17.0")

private func module(
    name: String,
    sources: String,
    resources: ResourceFileElements? = nil,
    dependencies: [TargetDependency] = []
) -> Target {
    .target(
        name: name,
        destinations: .iOS,
        product: .staticFramework,
        bundleId: "\(bundleIdPrefix).\(name)",
        deploymentTargets: deployment,
        buildableFolders: [.folder(path: sources)],
        resources: resources,
        dependencies: dependencies
    )
}

private func tests(name: String, sources: String, target: String) -> Target {
    .target(
        name: name,
        destinations: .iOS,
        product: .unitTests,
        bundleId: "\(bundleIdPrefix).\(name)",
        deploymentTargets: deployment,
        buildableFolders: [.folder(path: sources)],
        dependencies: [.target(name: target)]
    )
}

let project = Project(
    name: "MyIModules",
    settings: .settings(
        base: [
            "SWIFT_VERSION": "6.0",
            "SWIFT_STRICT_CONCURRENCY": "complete"
        ]
    ),
    targets: [
        module(
            name: "Domain",
            sources: "Sources/Domain"
        ),
        tests(
            name: "DomainTests",
            sources: "Tests/DomainTests",
            target: "Domain"
        ),

        module(
            name: "Clients",
            sources: "Sources/Clients",
            dependencies: [
                .target(name: "Domain"),
                .external(name: "ComposableArchitecture"),
                .external(name: "FirebaseCore"),
                .external(name: "FirebaseAuth"),
                .external(name: "FirebaseFirestore"),
                .external(name: "FirebaseStorage"),
                .external(name: "GoogleSignIn"),
                .external(name: "GoogleSignInSwift")
            ]
        ),
        tests(
            name: "ClientsTests",
            sources: "Tests/ClientsTests",
            target: "Clients"
        ),

        module(
            name: "DesignSystem",
            sources: "Sources/DesignSystem",
            resources: [
                "Sources/DesignSystem/Resources/Assets.xcassets",
                "Sources/DesignSystem/Resources/Fonts/**"
            ]
        ),

        module(
            name: "Features",
            sources: "Sources/Features",
            dependencies: [
                .target(name: "Domain"),
                .target(name: "Clients"),
                .target(name: "DesignSystem"),
                .external(name: "ComposableArchitecture")
            ]
        ),
        tests(
            name: "FeaturesTests",
            sources: "Tests/FeaturesTests",
            target: "Features"
        )
    ]
)
