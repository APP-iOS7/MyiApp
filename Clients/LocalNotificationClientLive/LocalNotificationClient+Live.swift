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
            let resolved: LocalNotificationAuthorization
            switch settings.authorizationStatus {
            case .notDetermined:
                resolved = .notDetermined
            case .denied:
                resolved = .denied
            case .authorized, .provisional, .ephemeral:
                resolved = .authorized
            @unknown default:
                resolved = .denied
            }
            AppLogger.debug("authorizationStatus = \(resolved) (raw=\(settings.authorizationStatus.rawValue))")
            return resolved
        },
        requestPermission: { @Sendable in
            let center = UNUserNotificationCenter.current()
            let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
            AppLogger.info("requestPermission granted=\(granted)")
            return granted
        },
        schedule: { @Sendable request async throws(LocalNotificationError) -> Void in
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

public extension DependencyValues {
    var localNotificationClient: LocalNotificationClient {
        get { self[LocalNotificationClient.self] }
        set { self[LocalNotificationClient.self] = newValue }
    }
}
