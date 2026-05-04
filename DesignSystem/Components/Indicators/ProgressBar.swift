import SwiftUI

public struct ProgressBar: View {
    public let ratio: CGFloat
    public let tintColor: Color

    public init(ratio: CGFloat, tintColor: Color) {
        self.ratio = ratio
        self.tintColor = tintColor
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.Semantic.progressTrack)

                Capsule()
                    .fill(tintColor)
                    .frame(width: proxy.size.width * ratio)
            }
        }
        .frame(height: ProgressBarLayout.height)
    }
}
