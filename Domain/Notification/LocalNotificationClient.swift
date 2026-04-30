import Foundation

public struct LocalNotificationClient: Sendable {
    public var requestPermission: @Sendable () async -> Bool
    public var schedule: @Sendable (LocalNotificationRequest) async throws(LocalNotificationError) -> Void
    public var cancel: @Sendable (UUID) async -> Void

    public init(
        requestPermission: @escaping @Sendable () async -> Bool,
        schedule: @escaping @Sendable (LocalNotificationRequest) async throws(LocalNotificationError) -> Void,
        cancel: @escaping @Sendable (UUID) async -> Void
    ) {
        self.requestPermission = requestPermission
        self.schedule = schedule
        self.cancel = cancel
    }
}
