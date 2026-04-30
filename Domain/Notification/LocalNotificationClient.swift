import Foundation

public struct LocalNotificationClient: Sendable {
    public var authorizationStatus: @Sendable () async -> LocalNotificationAuthorization
    public var requestPermission: @Sendable () async -> Bool
    public var schedule: @Sendable (LocalNotificationRequest) async throws(LocalNotificationError) -> Void
    public var cancel: @Sendable (UUID) async -> Void

    public init(
        authorizationStatus: @escaping @Sendable () async -> LocalNotificationAuthorization,
        requestPermission: @escaping @Sendable () async -> Bool,
        schedule: @escaping @Sendable (LocalNotificationRequest) async throws(LocalNotificationError) -> Void,
        cancel: @escaping @Sendable (UUID) async -> Void
    ) {
        self.authorizationStatus = authorizationStatus
        self.requestPermission = requestPermission
        self.schedule = schedule
        self.cancel = cancel
    }
}
