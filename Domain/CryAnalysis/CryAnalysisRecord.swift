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

extension CryAnalysisRecord {
    public var aggregatedScores: [EmotionScore] {
        guard !windows.isEmpty else { return [] }

        let sumByEmotion = Dictionary(
            windows.flatMap(\.self).map { ($0.emotion, $0.confidence) },
            uniquingKeysWith: +
        )
        let windowCount = Double(windows.count)
        return sumByEmotion
            .map { EmotionScore(emotion: $0.key, confidence: $0.value / windowCount) }
            .sorted { $0.confidence > $1.confidence }
    }
}
