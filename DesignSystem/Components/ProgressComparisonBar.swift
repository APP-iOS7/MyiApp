import SwiftUI

public struct ProgressBar: View {
    public let ratio: CGFloat
    public let tintColor: Color

    public init(ratio: CGFloat, tintColor: Color) {
        self.ratio = ratio
        self.tintColor = tintColor
    }

    public var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(Color.Semantic.progressTrack)
                .frame(maxWidth: .infinity)

            Capsule()
                .fill(tintColor)
                .containerRelativeFrame(.horizontal, alignment: .leading) { width, _ in
                    width * ratio
                }
        }
        .frame(height: ProgressBarLayout.height)
    }
}

#Preview {
    VStack(spacing: 16) {
        ProgressBar(ratio: 1.0, tintColor: .blue)
        ProgressBar(ratio: 0.6, tintColor: .orange)
        ProgressBar(ratio: 0, tintColor: .green)
    }
    .padding()
}
