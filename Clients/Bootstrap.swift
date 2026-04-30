import Domain
import FirebaseCore
@preconcurrency import FirebaseMessaging
import GoogleSignIn
@preconcurrency import UserNotifications

public enum AppBootstrap {
    private static let notificationCoordinator = NotificationCoordinator()

    public static func configure() {
        FirebaseApp.configure()

        if let clientID = FirebaseApp.app()?.options.clientID {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        }

        Messaging.messaging().delegate = notificationCoordinator
        UNUserNotificationCenter.current().delegate = notificationCoordinator
        AppLogger.info("AppBootstrap configured")
    }

    public static func handle(url: URL) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }

    public static func handleAPNsToken(_ token: Data) {
        Messaging.messaging().apnsToken = token
        AppLogger.info("APNs token registered, bytes=\(token.count)")
    }

    public static func handleAPNsFailure(_ error: Error) {
        AppLogger.error("APNs registration failed: \(error)")
    }
}

private final class NotificationCoordinator: NSObject, @unchecked Sendable {}

extension NotificationCoordinator: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        AppLogger.info("FCM token received: \(fcmToken ?? "nil")")
    }
}

extension NotificationCoordinator: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        AppLogger.debug("foreground notification: \(notification.request.identifier)")
        completionHandler([.banner, .sound])
    }
}
