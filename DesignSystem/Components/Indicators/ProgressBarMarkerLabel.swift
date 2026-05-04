import SwiftUI

public struct ProgressBarMarkerLabel: View {
    public let ratio: CGFloat
    public let text: String

    public init(ratio: CGFloat, text: String) {
        self.ratio = ratio
        self.text = text
    }

    public var body: some View {
        MarkerLabelLayout(ratio: ratio) {
            Text(text)
                .font(.caption2)
                .foregroundColor(.Semantic.secondaryText)
        }
    }
}

private struct MarkerLabelLayout: Layout {
    let ratio: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard let label = subviews.first else { return .zero }

        let labelSize = label.sizeThatFits(.unspecified)
        return CGSize(
            width: proposal.width ?? labelSize.width,
            height: labelSize.height
        )
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard let label = subviews.first else { return }

        let labelSize = label.sizeThatFits(.unspecified)
        let leading = min(
            bounds.width * ratio,
            max(bounds.width - labelSize.width, 0)
        )
        label.place(
            at: CGPoint(x: bounds.minX + leading, y: bounds.minY),
            anchor: .topLeading,
            proposal: ProposedViewSize(labelSize)
        )
    }
}
