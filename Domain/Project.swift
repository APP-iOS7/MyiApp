import ProjectDescription

let project = Project(
    name: "Domain",
    targets: [
        .target(
            name: "Domain",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.myiapp.Domain",
            infoPlist: .default,
            sources: ["Sources/**"]
        ),
        .target(
            name: "DomainTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.myiapp.DomainTests",
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [.target(name: "Domain")]
        ),
    ]
)
