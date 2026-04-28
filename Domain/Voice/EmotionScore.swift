import Foundation

public struct EmotionScore: Codable, Hashable, Sendable {
    public let emotion: EmotionType
    public let confidence: Double

    public init(emotion: EmotionType, confidence: Double) {
        self.emotion = emotion
        self.confidence = confidence
    }
}
