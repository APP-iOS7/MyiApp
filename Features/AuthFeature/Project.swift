import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    name: "AuthFeature",
    additionalDependencies: [
        .project(target: "Core", path: "../../Core"),
        .sdk(name: "AuthenticationServices", type: .framework)
    ]
)
