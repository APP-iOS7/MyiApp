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
    ]
)
