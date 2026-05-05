import Domain
import Foundation
import GoogleSignIn
import os
import Shared
@preconcurrency import UserNotifications

public enum AppBootstrap {

    /// Google OAuth client ID. Hardcoded so we don't depend on
    /// `GoogleService-Info.plist`. Reverse of the `reversedClientId`
    /// declared in `Project.swift`.
    private static let googleClientID =
        "407010597429-3bmimc7cfigpbrqbsplf6vrtarauaqki.apps.googleusercontent.com"

    private static let notificationCoordinator = NotificationCoordinator()
    private static let pendingToken = OSAllocatedUnfairLock<Data?>(initialState: nil)
    private static let bootstrapped = OSAllocatedUnfairLock<Bool>(initialState: false)

    public static func configure() {
        let already = bootstrapped.withLock { current -> Bool in
            if current { return true }
            current = true
            return false
        }
        if already { return }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: googleClientID)
        UNUserNotificationCenter.current().delegate = notificationCoordinator

        // Whenever the session becomes authenticated, retry registering any
        // cached APNs token (it may have arrived before login completed).
        Task {
            for await session in AuthState.shared.stream() {
                guard session != nil else { continue }
                if let data = pendingToken.withLock({ $0 }) {
                    await registerCached(token: data)
                }
            }
        }

        AppLogger.info("AppBootstrap configured")
    }

    public static func handle(url: URL) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }

    /// Called from `AppDelegate.didRegisterForRemoteNotificationsWithDeviceToken`.
    public static func registerAPNsToken(_ data: Data) {
        pendingToken.withLock { $0 = data }
        Task { await registerCached(token: data) }
    }

    private static func registerCached(token data: Data) async {
        guard AuthState.shared.snapshot() != nil else {
            AppLogger.debug("APNs token registration deferred: not signed in")
            return
        }
        let hex = data.map { String(format: "%02x", $0) }.joined()
        #if DEBUG
        let environment = "sandbox"
        #else
        let environment = "production"
        #endif
        do {
            try await APIClient.shared.postNoResponse(
                "/devices/register",
                body: RegisterDeviceRequestDTO(token: hex, environment: environment)
            )
            AppLogger.info("APNs token registered env=\(environment)")
        } catch {
            AppLogger.error("APNs token register failed: \(error)")
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
