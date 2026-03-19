import Foundation

public struct Note: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let recordID: String
    public let content: String
    public let createdAt: Date

    public init(
        id: String = UUID().uuidString,
        recordID: String,
        content: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.recordID = recordID
        self.content = content
        self.createdAt = createdAt
    }
}

public struct VoiceRecord: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let recordID: String
    public let fileURL: URL
    public let duration: TimeInterval
    public let createdAt: Date

    public init(
        id: String = UUID().uuidString,
        recordID: String,
        fileURL: URL,
        duration: TimeInterval,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.recordID = recordID
        self.fileURL = fileURL
        self.duration = duration
        self.createdAt = createdAt
    }
}
