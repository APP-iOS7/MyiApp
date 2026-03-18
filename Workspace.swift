import ProjectDescription

let workspace = Workspace(
    name: "MyiApp",
    projects: [
        "./App",
        "./Domain",
        "./Core",
        "./DesignSystem",
        "./Features/AuthFeature",
        "./Features/HomeFeature",
        "./Features/NoteFeature"
    ]
)
