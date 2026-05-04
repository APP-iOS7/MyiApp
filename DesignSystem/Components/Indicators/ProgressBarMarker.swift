import SwiftUI

public struct ProgressBarMarker: View {
    public let ratio: CGFloat

    public init(ratio: CGFloat) {
        self.ratio = ratio
    }

    public var body: some View {
        GeometryReader { proxy in
            Rectangle()
                .fill(Color.Semantic.progressMarker)
                .frame(width: ProgressBarLayout.markerWidth, height: ProgressBarLayout.markerHeight)
                .offset(x: proxy.size.width * ratio)
        }
        .frame(height: ProgressBarLayout.markerHeight)
    }
}
