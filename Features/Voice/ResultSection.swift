import DesignSystem
import Domain
import SwiftUI

struct ResultSection: View {
    let display: CryAnalysisFeature.ResultDisplay
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            ConfidenceRing(
                iconAsset: display.primary.emotion.iconAsset,
                confidence: display.primary.confidence
            )

            Text(display.primary.emotion.displayName)
                .font(.title.weight(.bold))

            VStack(spacing: Spacing.s) {
                ForEach(display.others, id: \.emotion) { score in
                    HStack {
                        Text(score.emotion.displayName)
                        Spacer()
                        Text("\(Int(score.confidence * 100))%")
                            .monospacedDigit()
                    }
                    .font(.subheadline)
                    .foregroundColor(.Semantic.secondaryText)
                }
            }
            .padding(.horizontal, Spacing.l)

            Spacer()

            Button("완료", action: onDismiss)
                .buttonStyle(.primary)
        }
        .padding(Spacing.m)
    }
}

#Preview("Result") {
    ResultSection(
        display: .init(
            primary: EmotionScore(emotion: .hungry, confidence: 0.82),
            others: [
                EmotionScore(emotion: .tired, confidence: 0.10),
                EmotionScore(emotion: .lonely, confidence: 0.05),
                EmotionScore(emotion: .scared, confidence: 0.03)
            ]
        ),
        onDismiss: {}
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.Semantic.screenBackground)
}
