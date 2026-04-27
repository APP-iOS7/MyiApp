// swift-tools-version: 6.0
import PackageDescription

#if TUIST
import struct ProjectDescription.PackageSettings
import struct ProjectDescription.Settings

// Tuist는 SPM 패키지를 product별 Xcode 타깃으로 분리한다. 그 과정에서 SPM이 swiftSettings를 정의한
// 패키지의 `-package-name` 컴파일러 플래그가 일부 누락되어, `package` 접근제어자가 깨진다.
// (Tuist 이슈 #6203 / #7052 참고. 메인테이너가 권장하는 표준 우회.)
// 영향받는 패키지의 모든 product에 -package-name을 명시 주입한다.
private let packagesUsingPackageAccessLevel: [(name: String, targets: [String])] = [
    ("swift-collections", [
        "Collections", "OrderedCollections", "DequeModule",
        "BitCollections", "HashTreeCollections", "HeapModule",
        "_RopeModule", "InternalCollectionsUtilities"
    ]),
    ("xctest-dynamic-overlay", [
        "IssueReporting", "IssueReportingPackageSupport",
        "IssueReportingTestSupport", "XCTestDynamicOverlay"
    ]),
    ("swift-navigation", [
        "AppKitNavigation", "SwiftNavigation", "SwiftUINavigation",
        "UIKitNavigation", "UIKitNavigationShim"
    ]),
    ("swift-dependencies", [
        "Dependencies", "DependenciesMacros", "DependenciesMacrosPlugin",
        "DependenciesTestObserver", "DependenciesTestSupport"
    ]),
    ("swift-case-paths", [
        "CasePaths", "CasePathsCore", "CasePathsMacros"
    ]),
    ("swift-sharing", [
        "Sharing", "VersionMarkerModules"
    ])
]

private func makeTargetSettings() -> [String: Settings] {
    var result: [String: Settings] = [:]
    for (pkg, targets) in packagesUsingPackageAccessLevel {
        for target in targets {
            result[target] = .settings(base: [
                "OTHER_SWIFT_FLAGS": ["$(inherited)", "-package-name", pkg]
            ])
        }
    }
    return result
}

let packageSettings = PackageSettings(
    productTypes: [
        "ComposableArchitecture": .staticFramework
    ],
    targetSettings: makeTargetSettings()
)
#endif

let package = Package(
    name: "ExternalDependencies",
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            .upToNextMinor(from: "1.25.5")
        ),
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk",
            .upToNextMinor(from: "12.12.1")
        ),
        .package(
            url: "https://github.com/google/GoogleSignIn-iOS",
            .upToNextMinor(from: "9.1.0")
        )
    ]
)
