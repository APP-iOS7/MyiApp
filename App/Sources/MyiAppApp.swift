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
        FirebaseApp.configure()
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
