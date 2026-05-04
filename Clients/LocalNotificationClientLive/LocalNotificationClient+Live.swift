import ComposableArchitecture
import Domain
import Foundation
import Shared
import UserNotifications

extension LocalNotificationClient: @retroactive TestDependencyKey {}
extension LocalNotificationClient: @retroactive DependencyKey {
    public static let liveValue = Self(
        authorizationStatus: { @Sendable in
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            let resolved: LocalNotificationAuthorization = switch settings.authorizationStatus {
            case .notDetermined:
                .notDetermined
            case .denied:
                .denied
            case .authorized, .provisional, .ephemeral:
                .authorized
            @unknown default:
                .denied
            }
            AppLogger.debug("authorizationStatus = \(resolved) (raw=\(settings.authorizationStatus.rawValue))")
            return resolved
        },
        requestPermission: { @Sendable in
            let center = UNUserNotificationCenter.current()
            let granted = await (try? center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
            AppLogger.info("requestPermission granted=\(granted)")
            return granted
        },
        schedule: { @Sendable request async throws(LocalNotificationError) in
            guard request.scheduledAt > Date() else {
                AppLogger.error("schedule rejected: scheduledInPast id=\(request.id) at=\(request.scheduledAt)")
                throw .scheduledInPast
            }

            let content = UNMutableNotificationContent()
            content.title = request.title
            if let body = request.body, !body.isEmpty {
                content.body = body
            }
            content.sound = .default

            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: request.scheduledAt
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let unRequest = UNNotificationRequest(
                identifier: request.id.uuidString,
                content: content,
                trigger: trigger
            )

            do {
                try await UNUserNotificationCenter.current().add(unRequest)
                AppLogger.debug("scheduled id=\(request.id) at=\(request.scheduledAt)")
            } catch {
                AppLogger.error("schedule failed: \(error) id=\(request.id)")
                throw .schedulingFailed
            }
        },
        cancel: { @Sendable id in
            UNUserNotificationCenter.current()
                .removePendingNotificationRequests(withIdentifiers: [id.uuidString])
            AppLogger.debug("cancelled id=\(id)")
        }
    )
}

extension DependencyValues {
    public var localNotificationClient: LocalNotificationClient {
        get { self[LocalNotificationClient.self] }
        set { self[LocalNotificationClient.self] = newValue }
    }
}
