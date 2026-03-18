import ProjectDescription

// ProjectDescriptionHelpers: 매니페스트 간 공유 코드

// MARK: - App 메타 정보

public enum AppInfo {
    public static let marketingVersion = "1.2.6"
    public static let buildNumber = "1"
    public static let developmentTeam = "59FP2PXRXK"

    public enum Permissions {
        public static let camera = "아기의 사진을 찍어서 일지에 추가하기 위해 카메라에 접근합니다."
        public static let microphone = "아기의 울음 소리를 분석하기 위해 마이크 권한이 필요합니다."
        public static let photoLibrary = "아기의 사진을 일지에 추가하기 위해 사진 라이브러리에 접근합니다."
        public static let notifications = "일정 알림을 보내기 위해 알림 권한이 필요합니다."
    }

    public enum URLScheme {
        public static let googleSignIn = "com.googleusercontent.apps.522055025991-52l80ebg7917h1mmfad75eh9khsuaklb"
    }

    public enum Fonts {
        public static let bmjua = "BMJUA.otf"
    }
}

public extension InfoPlist {
    static var app: InfoPlist {
        .extendingDefault(with: [
            "CFBundleDisplayName": "My i",
            "LSApplicationCategoryType": "public.app-category.lifestyle",
            "NSCameraUsageDescription": .string(AppInfo.Permissions.camera),
            "NSMicrophoneUsageDescription": .string(AppInfo.Permissions.microphone),
            "NSPhotoLibraryUsageDescription": .string(AppInfo.Permissions.photoLibrary),
            "NSUserNotificationsUsageDescription": .string(AppInfo.Permissions.notifications),
            "CFBundleURLTypes": .array([
                .dictionary([
                    "CFBundleTypeRole": "Editor",
                    "CFBundleURLName": "googleSignIn",
                    "CFBundleURLSchemes": .array([.string(AppInfo.URLScheme.googleSignIn)])
                ])
            ]),
            "UIAppFonts": .array([.string(AppInfo.Fonts.bmjua)])
        ])
    }
}

public extension Settings {
    static var app: Settings {
        .settings(base: SettingsDictionary()
            .marketingVersion(AppInfo.marketingVersion)
            .currentProjectVersion(AppInfo.buildNumber)
            .merging(["DEVELOPMENT_TEAM": .string(AppInfo.developmentTeam)])
        )
    }
}

// MARK: -

public enum DeploymentTarget {
    public static let iOS: DeploymentTargets = .iOS("17.0")
}

public enum BundleID {
    fileprivate static let base = "kr.co.codegroove.MyiApp"

    public static let app = base
    public static let appTests = "\(base).Tests"

    public static let domain = "\(base).Domain"
    public static let domainTests = "\(base).Domain.Tests"

    public static let core = "\(base).Core"

    public static let designSystem = "\(base).DesignSystem"

    /// Feature 타겟용 Bundle ID 생성
    /// - Parameters:
    ///   - name: 피처 이름 (예: "HomeFeature")
    ///   - suffix: 타겟 종류 (예: "Interface", "Testing", "Tests", "Example"). nil이면 Source 타겟
    public static func feature(_ name: String, _ suffix: String? = nil) -> String {
        guard let suffix else { return "\(base).\(name)" }
        return "\(base).\(name).\(suffix)"
    }
}

public extension TargetScript {
    static var swiftFormat: TargetScript {
        .pre(
            tool: "swiftformat",
            arguments: ["$SRCROOT"],
            name: "SwiftFormat",
            basedOnDependencyAnalysis: false
        )
    }
}

// MARK: - Feature 프로젝트 팩토리

public extension Project {
    /// TMA 표준 5타겟 Feature 프로젝트를 생성합니다.
    ///
    /// 생성되는 타겟:
    /// - `{name}Interface` — 공개 API (프로토콜, 모델)
    /// - `{name}` — 실제 구현 (UI, Reducer)
    /// - `{name}Testing` — Mock/Stub 제공 (다른 모듈 테스트 시 사용)
    /// - `{name}Tests` — 유닛 테스트
    /// - `{name}Example` — 독립 실행 앱 (개발/디자인 미리보기)
    static func feature(
        name: String,
        domainPath: Path = "../../Domain",
        designSystemPath: Path = "../../DesignSystem"
    ) -> Project {
        Project(
            name: name,
            targets: FeatureTargets(name: name, domainPath: domainPath, designSystemPath: designSystemPath).all
        )
    }
}

// MARK: -

private struct FeatureTargets {
    let name: String
    let domainPath: Path
    let designSystemPath: Path

    var all: [Target] { [interface, source, testing, tests, example] }

    private var interface: Target {
        .target(
            name: "\(name)Interface",
            destinations: .iOS,
            product: .framework,
            bundleId: BundleID.feature(name, "Interface"),
            deploymentTargets: DeploymentTarget.iOS,
            infoPlist: .default,
            sources: ["Sources/\(name)Interface/**"],
            scripts: [.swiftFormat],
            dependencies: [.project(target: "Domain", path: domainPath)]
        )
    }

    private var source: Target {
        .target(
            name: name,
            destinations: .iOS,
            product: .framework,
            bundleId: BundleID.feature(name),
            deploymentTargets: DeploymentTarget.iOS,
            infoPlist: .default,
            sources: ["Sources/\(name)/**"],
            scripts: [.swiftFormat],
            dependencies: [
                .target(name: "\(name)Interface"),
                .project(target: "DesignSystem", path: designSystemPath)
            ]
        )
    }

    private var testing: Target {
        .target(
            name: "\(name)Testing",
            destinations: .iOS,
            product: .framework,
            bundleId: BundleID.feature(name, "Testing"),
            deploymentTargets: DeploymentTarget.iOS,
            infoPlist: .default,
            sources: ["Sources/\(name)Testing/**"],
            scripts: [.swiftFormat],
            dependencies: [.target(name: "\(name)Interface")]
        )
    }

    private var tests: Target {
        .target(
            name: "\(name)Tests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: BundleID.feature(name, "Tests"),
            deploymentTargets: DeploymentTarget.iOS,
            infoPlist: .default,
            sources: ["Tests/\(name)Tests/**"],
            scripts: [.swiftFormat],
            dependencies: [
                .target(name: name),
                .target(name: "\(name)Testing")
            ]
        )
    }

    private var example: Target {
        .target(
            name: "\(name)Example",
            destinations: .iOS,
            product: .app,
            bundleId: BundleID.feature(name, "Example"),
            deploymentTargets: DeploymentTarget.iOS,
            infoPlist: .extendingDefault(with: ["CFBundleDisplayName": .string("\(name)Example")]),
            sources: ["Sources/\(name)Example/**"],
            scripts: [.swiftFormat],
            dependencies: [
                .target(name: name),
                .target(name: "\(name)Testing")
            ]
        )
    }
}
