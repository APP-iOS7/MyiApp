import ProjectDescription

let tuist = Tuist(
    compatibleXcodeVersions: .upToNextMajor("16.4"),
    fullHandle: "qjatn0545/MyiApp",
    swiftVersion: "6.2.4",
    generationOptions: .options(
        enableCaching: true,
        registryEnabled: true,
        warningsAsErrors: .all
    )
)