import ProjectDescription

let project = Project(
    name: "MyiApp",
    targets: [
        .target(
            name: "MyiApp",
            destinations: .iOS,
            product: .app,
            bundleId: "kr.co.codegroove.MyiApp",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(with: [
                "UILaunchStoryboardName": .string("LaunchScreen")
            ]),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            entitlements: .dictionary([
                "com.apple.developer.applesignin": ["Default"]
            ]),
            scripts: [
                .pre(
                    tool: "swiftformat",
                    arguments: ["$SRCROOT/Sources", "--config", "$SRCROOT/../.swiftformat"],
                    name: "SwiftFormat",
                    basedOnDependencyAnalysis: false
                )
            ],
            dependencies: [
                .external(name: "ComposableArchitecture"),
                .external(name: "FirebaseAuth"),
                .external(name: "FirebaseFirestore"),
                .external(name: "FirebaseStorage")
            ],
            settings: .settings(
                base: SettingsDictionary()
                    .otherLinkerFlags(["$(inherited)", "-ObjC"])
            )
        )
    ]
)