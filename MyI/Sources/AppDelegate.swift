import Clients
import DesignSystem
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    )
        -> Bool
    {
        AppBootstrap.configure()
        DesignSystemFontFamily.registerAllCustomFonts()
        application.registerForRemoteNotifications()
        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    )
        -> Bool
    {
        AppBootstrap.handle(url: url)
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        AppBootstrap.registerAPNsToken(deviceToken)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: any Error
    ) {
        // No-op; APNs registration may legitimately fail on the simulator.
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        let payload: [String: String] = Dictionary(uniqueKeysWithValues: userInfo.compactMap { key, value in
            guard let key = key as? String, let value = value as? String else { return nil }

            return (key, value)
        })
        Task {
            await AppBootstrap.handleRemoteNotification(payload: payload)
            completionHandler(.newData)
        }
    }
}
