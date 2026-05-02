import Domain
@preconcurrency import FirebaseAuth
import FirebaseCore
@preconcurrency import FirebaseFirestore
@preconcurrency import FirebaseMessaging
import GoogleSignIn
import Shared
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

    public static func saveFCMToken(_ token: String) async {
        guard let uid = Auth.auth().currentUser?.uid else {
            AppLogger.debug("FCM token save skipped: not authenticated")
            return
        }
        do {
            try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .setData(["fcmToken": token], merge: true)
            AppLogger.info("FCM token saved for \(uid)")
        } catch {
            AppLogger.error("FCM token save failed: \(error)")
        }
    }

    public static func handleRemoteNotification(payload: [String: String]) async {
        guard let type = payload["type"],
              let noteIDString = payload["noteID"],
              let noteID = UUID(uuidString: noteIDString)
        else {
            AppLogger.error("invalid push payload: \(payload)")
            return
        }

        switch type {
        case "note_created":
            guard let title = payload["title"],
                  let scheduledAtString = payload["reminderScheduledAt"],
                  !scheduledAtString.isEmpty,
                  let scheduledAtMillis = Double(scheduledAtString)
            else {
                AppLogger.info("note_created without reminder, skip schedule")
                return
            }
            let scheduledAt = Date(timeIntervalSince1970: scheduledAtMillis / 1000)
            guard scheduledAt > Date() else {
                AppLogger.debug("scheduledAt in past, skip schedule")
                return
            }
            let body = payload["body"] ?? ""
            await scheduleLocalReminder(
                id: noteID,
                title: title,
                body: body.isEmpty ? nil : body,
                scheduledAt: scheduledAt
            )

        case "note_deleted":
            cancelLocalReminder(id: noteID)

        default:
            AppLogger.error("unknown push type: \(type)")
        }
    }

    private static func scheduleLocalReminder(id: UUID, title: String, body: String?, scheduledAt: Date) async {
        let content = UNMutableNotificationContent()
        content.title = title
        if let body, !body.isEmpty {
            content.body = body
        }
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: scheduledAt
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: id.uuidString,
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            AppLogger.info("push-driven schedule id=\(id) at=\(scheduledAt)")
        } catch {
            AppLogger.error("push-driven schedule failed: \(error) id=\(id)")
        }
    }

    private static func cancelLocalReminder(id: UUID) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [id.uuidString])
        AppLogger.info("push-driven cancel id=\(id)")
    }
}

private final class NotificationCoordinator: NSObject, @unchecked Sendable {}

extension NotificationCoordinator: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        AppLogger.info("FCM token received: \(fcmToken ?? "nil")")
        guard let fcmToken else { return }
        Task { await AppBootstrap.saveFCMToken(fcmToken) }
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
