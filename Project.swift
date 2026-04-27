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
            name: "Domain",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "kr.co.codegrove.Domain",
            deploymentTargets: .iOS("17.0"),
            buildableFolders: ["Domain"]
        ),
        .target(
            name: "Clients",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "kr.co.codegrove.Clients",
            deploymentTargets: .iOS("17.0"),
            buildableFolders: ["Clients"],
            dependencies: [
                .target(name: "Domain"),
                .external(name: "ComposableArchitecture"),
                .external(name: "FirebaseCore"),
                .external(name: "FirebaseAuth"),
                .external(name: "FirebaseFirestore"),
                .external(name: "FirebaseStorage"),
                .external(name: "GoogleSignIn"),
                .external(name: "GoogleSignInSwift")
            ]
        ),
        .target(
            name: "DesignSystem",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "kr.co.codegrove.DesignSystem",
            deploymentTargets: .iOS("17.0"),
            buildableFolders: ["DesignSystem"]
        ),
        .target(
            name: "Features",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "kr.co.codegrove.Features",
            deploymentTargets: .iOS("17.0"),
            buildableFolders: ["Features"],
            dependencies: [
                .target(name: "Domain"),
                .target(name: "Clients"),
                .target(name: "DesignSystem"),
                .external(name: "ComposableArchitecture")
            ]
        ),
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
                .target(name: "Features")
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
