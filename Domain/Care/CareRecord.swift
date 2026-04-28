import Foundation

public struct CareRecord: Identifiable, Hashable, Sendable, Codable {
    public let id: UUID
    public var createdAt: Date
    public var event: CareEvent
    public var content: String?

    public init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        event: CareEvent,
        content: String? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.event = event
        self.content = content
    }
}
