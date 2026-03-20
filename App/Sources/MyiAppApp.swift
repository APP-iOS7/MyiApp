import ComposableArchitecture
import FirebaseCore
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    )
        -> Bool
    {
        // 테스트 환경인 경우 Firebase 초기화를 건너뜁니다.
        let isUnitTesting = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_TESTS"] == "YES"
            || NSClassFromString("XCTestCase") != nil
            || ProcessInfo.processInfo.environment["CI"] != nil && Bundle.main.bundleIdentifier?
            .contains("Tests") == true

        if !isUnitTesting {
            // GoogleService-Info.plist 파일이 실제로 존재하는지 확인 후 초기화 (CI 등에서 누락 시 크래시 방지)
            if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
                FirebaseApp.configure()
            } else {
                print("⚠️ Warning: GoogleService-Info.plist not found. Skipping Firebase configuration.")
            }
        }

        return true
    }
}

@main
struct MyiAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var delegate

    let store = Store(initialState: RootFeature.State()) {
        RootFeature()
    }

    var body: some Scene {
        WindowGroup {
            RootView(store: self.store)
        }
    }
}
