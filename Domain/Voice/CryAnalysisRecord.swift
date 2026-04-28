import Foundation

public struct CryAnalysisRecord: Identifiable, Hashable, Sendable, Codable {
    public let id: UUID
    public var createdAt: Date
    public var windows: [[EmotionScore]]

    public init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        windows: [[EmotionScore]]
    ) {
        self.id = id
        self.createdAt = createdAt
        self.windows = windows
    }
}
