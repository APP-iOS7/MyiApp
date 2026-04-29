import Foundation

public struct Note: Identifiable, Hashable, Sendable, Codable {
    public let id: UUID
    public var kind: NoteKind
    public var title: String
    public var description: String
    public var date: Date
    public var imageURLs: [URL]
    public var reminder: Reminder?
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        kind: NoteKind,
        title: String,
        description: String = "",
        date: Date,
        imageURLs: [URL] = [],
        reminder: Reminder? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.description = description
        self.date = date
        self.imageURLs = imageURLs
        self.reminder = reminder
        self.createdAt = createdAt
    }
}

public enum NoteKind: String, Hashable, Sendable, Codable {
    case diary
    case schedule
}

public struct Reminder: Hashable, Sendable, Codable {
    public var scheduledAt: Date

    public init(scheduledAt: Date) {
        self.scheduledAt = scheduledAt
    }
}
