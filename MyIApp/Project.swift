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
                "UILaunchStoryboardName": .string("LaunchScreen"),
                "UIAppFonts": .array([
                    .string("BMJUA.otf")
                ]),
                "CFBundleURLTypes": .array([
                    .dictionary([
                        "CFBundleURLSchemes": .array([
                            .string("com.googleusercontent.apps.522055025991-52l80ebg7917h1mmfad75eh9khsuaklb")
                        ])
                    ])
                ])
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
                .external(name: "FirebaseStorage"),
                .external(name: "GoogleSignIn")
            ],
            settings: .settings(
                base: SettingsDictionary()
                    .otherLinkerFlags(["$(inherited)", "-ObjC"])
            )
        )
    ]
)