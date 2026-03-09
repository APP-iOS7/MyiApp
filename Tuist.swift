import ProjectDescription

let tuist = Tuist(
    fullHandle: "qjatn0545/MyiApp",
    swiftVersion: "6.2",
    generationOptions: .options(
        enableCaching: true,
        registryEnabled: true,
        warningsAsErrors: .all
    )
)