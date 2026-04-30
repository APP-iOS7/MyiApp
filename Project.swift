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
                .external(name: "FirebaseMessaging"),
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
            product: .framework,
            bundleId: "kr.co.codegrove.Features",
            deploymentTargets: .iOS("17.0"),
            buildableFolders: ["Features"],
            dependencies: [
                .target(name: "Domain"),
                .target(name: "Clients"),
                .target(name: "DesignSystem"),
                .external(name: "ComposableArchitecture")
            ],
            settings: .settings(base: [
                "OTHER_LDFLAGS": ["$(inherited)", "-ObjC"]
            ])
        ),
        .target(
            name: "MyI",
            destinations: .iOS,
            product: .app,
            bundleId: "kr.co.codegrove.MyI",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(with: [
                "UILaunchStoryboardName": "LaunchScreen",
                "NSMicrophoneUsageDescription": "아이의 울음소리를 분석하기 위해 마이크 권한이 필요합니다.",
                "UIBackgroundModes": ["remote-notification"],
                "CFBundleURLTypes": [
                    [
                        "CFBundleTypeRole": "Editor",
                        "CFBundleURLSchemes": [
                            "com.googleusercontent.apps.407010597429-1tmg5nqub6tgiohmgd0q5sofkpd3kp99"
                        ]
                    ]
                ]
            ]),
            sources: ["MyI/Models/**"],
            buildableFolders: [
                "MyI/Sources",
                "MyI/Resources"
            ],
            entitlements: .dictionary([
                "com.apple.developer.applesignin": .array(["Default"]),
                "aps-environment": .string("development")
            ]),
            dependencies: [
                .target(name: "Features"),
                .target(name: "Clients"),
                .target(name: "DesignSystem"),
                .external(name: "ComposableArchitecture")
            ],
            settings: .settings(
                base: [
                    "MARKETING_VERSION": "1.0",
                    "CURRENT_PROJECT_VERSION": "1",
                    "CODE_SIGN_STYLE": "Automatic",
                    "CODE_SIGN_ALLOW_ENTITLEMENTS_MODIFICATION": "YES",
                    "OTHER_LDFLAGS": ["$(inherited)", "-ObjC"]
                ]
            )
        )
    ]
)
