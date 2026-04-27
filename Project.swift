import ProjectDescription

let project = Project(
    name: "MyI",
    organizationName: "codegrove",
    settings: .settings(
        base: [
            "DEVELOPMENT_TEAM": "59FP2PXRXK",
            "SWIFT_VERSION": "6.0"
        ]
    ),
    targets: [
        .target(
            name: "MyI",
            destinations: .iOS,
            product: .app,
            bundleId: "kr.co.codegrove.MyI",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(with: [
                "UILaunchStoryboardName": "LaunchScreen",
                "CFBundleURLTypes": [
                    [
                        "CFBundleTypeRole": "Editor",
                        "CFBundleURLSchemes": [
                            "com.googleusercontent.apps.407010597429-1tmg5nqub6tgiohmgd0q5sofkpd3kp99"
                        ]
                    ]
                ]
            ]),
            buildableFolders: [
                "MyI/Sources",
                "MyI/Resources"
            ],
            entitlements: .dictionary([
                "com.apple.developer.applesignin": .array(["Default"])
            ]),
            dependencies: [
                .project(target: "Features", path: "Modules")
            ],
            settings: .settings(
                base: [
                    "MARKETING_VERSION": "1.0",
                    "CURRENT_PROJECT_VERSION": "1",
                    "CODE_SIGN_STYLE": "Automatic"
                ]
            )
        )
    ]
)
