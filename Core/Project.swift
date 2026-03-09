import ProjectDescription

let project = Project(
    name: "Core",
    targets: [
        .target(
            name: "Core",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.myiapp.Core",
            infoPlist: .default,
            sources: ["Sources/**"],
            dependencies: [.project(target: "Domain", path: "../Domain")]
        )
    ]
)
