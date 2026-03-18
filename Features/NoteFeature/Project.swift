import ProjectDescription

let project = Project(
    name: "NoteFeature",
    targets: [
        .target(
            name: "NoteFeatureInterface",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.myiapp.NoteFeatureInterface",
            infoPlist: .default,
            sources: ["Sources/NoteFeatureInterface/**"],
            dependencies: [.project(target: "Domain", path: "../../Domain")]
        ),
        .target(
            name: "NoteFeature",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.myiapp.NoteFeature",
            infoPlist: .default,
            sources: ["Sources/NoteFeature/**"],
            dependencies: [
                .target(name: "NoteFeatureInterface"),
                .project(target: "DesignSystem", path: "../../DesignSystem")
            ]
        )
    ]
)
