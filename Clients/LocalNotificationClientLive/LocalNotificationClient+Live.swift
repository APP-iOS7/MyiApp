import ComposableArchitecture
import Domain
import Foundation
import UserNotifications

extension LocalNotificationClient: @retroactive TestDependencyKey {}
extension LocalNotificationClient: @retroactive DependencyKey {
    public static let liveValue = Self(
        requestPermission: { @Sendable in
            let center = UNUserNotificationCenter.current()
            let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
            return granted
        },
        schedule: { @Sendable request async throws(LocalNotificationError) -> Void in
            guard request.scheduledAt > Date() else {
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
            } catch {
                throw .schedulingFailed
            }
        },
        cancel: { @Sendable id in
            UNUserNotificationCenter.current()
                .removePendingNotificationRequests(withIdentifiers: [id.uuidString])
        }
    )
}

public extension DependencyValues {
    var localNotificationClient: LocalNotificationClient {
        get { self[LocalNotificationClient.self] }
        set { self[LocalNotificationClient.self] = newValue }
    }
}
