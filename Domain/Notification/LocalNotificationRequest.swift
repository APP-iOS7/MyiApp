import Foundation

public struct LocalNotificationRequest: Hashable, Sendable {
    public let id: UUID
    public let title: String
    public let body: String?
    public let scheduledAt: Date

    public init(id: UUID, title: String, body: String? = nil, scheduledAt: Date) {
        self.id = id
        self.title = title
        self.body = body
        self.scheduledAt = scheduledAt
    }
}
