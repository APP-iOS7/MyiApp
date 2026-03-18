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
                "CFBundleDisplayName": "My i",
                "LSApplicationCategoryType": "public.app-category.lifestyle",
                "NSCameraUsageDescription": "아기의 사진을 찍어서 일지에 추가하기 위해 카메라에 접근합니다.",
                "NSMicrophoneUsageDescription": "아기의 울음 소리를 분석하기 위해 마이크 권한이 필요합니다.",
                "NSPhotoLibraryUsageDescription": "아기의 사진을 일지에 추가하기 위해 사진 라이브러리에 접근합니다.",
                "NSUserNotificationsUsageDescription": "일정 알림을 보내기 위해 알림 권한이 필요합니다.",
                "CFBundleURLTypes": [
                    [
                        "CFBundleTypeRole": "Editor",
                        "CFBundleURLName": "googleSignIn",
                        "CFBundleURLSchemes": [
                            "com.googleusercontent.apps.522055025991-52l80ebg7917h1mmfad75eh9khsuaklb"
                        ]
                    ]
                ],
                "UIAppFonts": ["BMJUA.otf"]
            ]),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            entitlements: .file(path: "MyiApp.entitlements"),
            dependencies: [
                .project(target: "AuthFeature", path: "../Features/AuthFeature"),
                .project(target: "HomeFeature", path: "../Features/HomeFeature"),
                .project(target: "DesignSystem", path: "../DesignSystem"),
                .project(target: "Core", path: "../Core")
            ],
            settings: .settings(base: [
                "MARKETING_VERSION": "1.2.6",
                "CURRENT_PROJECT_VERSION": "1",
                "DEVELOPMENT_TEAM": "59FP2PXRXK"
            ])
        ),
        .target(
            name: "MyiAppTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "kr.co.codegroove.MyiAppTests",
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [.target(name: "MyiApp")]
        )
    ]
)
