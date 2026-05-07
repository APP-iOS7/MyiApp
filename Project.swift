import ProjectDescription

let marketingVersion = "1.3.1"
let buildNumber = "2"
let appBundleId = "kr.co.codegroove.MyiApp"
let reversedClientId = "com.googleusercontent.apps.407010597429-3bmimc7cfigpbrqbsplf6vrtarauaqki"

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
            name: "Shared",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "kr.co.codegrove.Shared",
            deploymentTargets: .iOS("17.0"),
            buildableFolders: ["Shared"]
        ),
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
            sources: ["Clients/**/*.swift"],
            resources: ["Clients/CryAnalysisClientLive/Resources/**"],
            dependencies: [
                .target(name: "Shared"),
                .target(name: "Domain"),
                .external(name: "ComposableArchitecture"),
                .external(name: "ConcurrencyExtras"),
                .external(name: "FirebaseCore"),
                .external(name: "FirebaseAuth"),
                .external(name: "FirebaseFirestore"),
                .external(name: "FirebaseStorage"),
                .external(name: "FirebaseMessaging"),
                .external(name: "FirebaseCrashlytics"),
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
            buildableFolders: ["DesignSystem"],
            dependencies: [
                .target(name: "Shared")
            ]
        ),
        .target(
            name: "Features",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "kr.co.codegrove.Features",
            deploymentTargets: .iOS("17.0"),
            buildableFolders: ["Features"],
            dependencies: [
                .target(name: "Shared"),
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
            bundleId: appBundleId,
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(with: [
                "CFBundleShortVersionString": "$(MARKETING_VERSION)",
                "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
                "UILaunchStoryboardName": "LaunchScreen",
                "ITSAppUsesNonExemptEncryption": false,
                "NSMicrophoneUsageDescription": "아기의 울음소리를 분석하기 위해 마이크 권한이 필요합니다.",
                "UIBackgroundModes": ["remote-notification"],
                "CFBundleURLTypes": [
                    [
                        "CFBundleTypeRole": "Editor",
                        "CFBundleURLSchemes": [
                            .string(reversedClientId)
                        ]
                    ]
                ]
            ]),
            buildableFolders: [
                "MyI/Sources",
                "MyI/Resources"
            ],
            entitlements: .dictionary([
                "com.apple.developer.applesignin": .array(["Default"]),
                "aps-environment": .string("production")
            ]),
            scripts: [
                .post(
                    script: """
                    SCRIPT="${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run"
                    [ -f "$SCRIPT" ] || SCRIPT="${SRCROOT}/Tuist/.build/checkouts/firebase-ios-sdk/Crashlytics/run"
                    "$SCRIPT"
                    """,
                    name: "Firebase Crashlytics dSYM Upload",
                    inputPaths: [
                        "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${TARGET_NAME}",
                        "$(SRCROOT)/$(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)"
                    ]
                )
            ],
            dependencies: [
                .target(name: "Domain"),
                .target(name: "Clients"),
                .target(name: "DesignSystem"),
                .target(name: "Features"),
                .external(name: "ComposableArchitecture")
            ],
            settings: .settings(
                base: [
                    "MARKETING_VERSION": .string(marketingVersion),
                    "CURRENT_PROJECT_VERSION": .string(buildNumber),
                    "CODE_SIGN_STYLE": "Automatic",
                    "CODE_SIGN_ALLOW_ENTITLEMENTS_MODIFICATION": "YES",
                    "OTHER_LDFLAGS": ["$(inherited)", "-ObjC"],
                    "TARGETED_DEVICE_FAMILY": "1"
                ]
            )
        ),
        .target(
            name: "FeaturesTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "kr.co.codegrove.FeaturesTests",
            deploymentTargets: .iOS("17.0"),
            sources: ["FeaturesTests/**/*.swift"],
            dependencies: [
                .target(name: "Features")
            ]
        ),
        .target(
            name: "MyITests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "kr.co.codegrove.MyITests",
            deploymentTargets: .iOS("17.0"),
            sources: ["MyI/Tests/**/*.swift"],
            dependencies: [
                .target(name: "MyI")
            ]
        )
    ]
)
