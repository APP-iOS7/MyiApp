import SwiftUI

public struct ConfidenceRing: View {
    let iconAsset: DesignSystemImages
    let confidence: Double

    public init(iconAsset: DesignSystemImages, confidence: Double) {
        self.iconAsset = iconAsset
        self.confidence = confidence
    }

    public var body: some View {
        GeometryReader { proxy in
            let available = min(proxy.size.width, proxy.size.height)
            let stroke = available * ConfidenceRingLayout.strokeRatio
            let iconSide = available * ConfidenceRingLayout.iconRatio
            let percentSize = available * ConfidenceRingLayout.percentTextRatio

            ZStack {
                Circle()
                    .stroke(Color.Semantic.progressTrack, lineWidth: stroke)
                    .padding(stroke / 2)

                Circle()
                    .trim(from: 0, to: CGFloat(confidence))
                    .stroke(
                        Color.Semantic.primaryAction,
                        style: StrokeStyle(lineWidth: stroke, lineCap: .round)
                    )
                    .padding(stroke / 2)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 0) {
                    Image(iconAsset)
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconSide, height: iconSide)

                    Text("\(Int(confidence * 100))%")
                        .font(.system(size: percentSize, weight: .semibold))
                        .monospacedDigit()
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    VStack(spacing: 24) {
        ConfidenceRing(iconAsset: Asset.Analysis.hungry, confidence: 0.82)
        ConfidenceRing(iconAsset: Asset.Analysis.tired, confidence: 0.45)
    }
    .padding()
}
