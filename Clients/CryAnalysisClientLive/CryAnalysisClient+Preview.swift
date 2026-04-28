#if DEBUG
import Domain
import Foundation

extension CryAnalysisClient {
    public static let previewValue = Self(
        analyze: { @Sendable _ async throws(CryAnalysisError) -> CryAnalysisRecord in
            try? await Task.sleep(for: .milliseconds(500))
            return CryAnalysisRecord(windows: [
                [
                    EmotionScore(emotion: .hungry,    confidence: 0.78),
                    EmotionScore(emotion: .tired,     confidence: 0.12),
                    EmotionScore(emotion: .lonely,    confidence: 0.06),
                    EmotionScore(emotion: .scared,    confidence: 0.02),
                    EmotionScore(emotion: .coldHot,   confidence: 0.02),
                ],
                [
                    EmotionScore(emotion: .hungry,    confidence: 0.85),
                    EmotionScore(emotion: .tired,     confidence: 0.08),
                    EmotionScore(emotion: .lonely,    confidence: 0.04),
                    EmotionScore(emotion: .scared,    confidence: 0.02),
                    EmotionScore(emotion: .coldHot,   confidence: 0.01),
                ],
            ])
        }
    )
}
#endif
