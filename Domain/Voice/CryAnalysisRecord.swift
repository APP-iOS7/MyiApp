import Foundation

public struct CryAnalysisRecord: Identifiable, Hashable, Sendable, Codable {
    public let id: UUID
    public var createdAt: Date
    public var primaryEmotion: EmotionType
    public var primaryConfidence: Double

    public init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        primaryEmotion: EmotionType,
        primaryConfidence: Double
    ) {
        self.id = id
        self.createdAt = createdAt
        self.primaryEmotion = primaryEmotion
        self.primaryConfidence = primaryConfidence
    }
}
