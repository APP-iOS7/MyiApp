import SwiftUI

/// 리스트 행의 좌측 타임라인 시각 — 위/아래 연결선과 가운데 점.
public struct TimelineTrack: View {
    private let tintColor: Color
    private let showTopLine: Bool
    private let showBottomLine: Bool

    private let dotSize: CGFloat = 10
    private let lineWidth: CGFloat = 2

    public init(
        tintColor: Color,
        showTopLine: Bool,
        showBottomLine: Bool
    ) {
        self.tintColor = tintColor
        self.showTopLine = showTopLine
        self.showBottomLine = showBottomLine
    }

    public var body: some View {
        VStack(spacing: 0) {
            line(visible: showTopLine)
            Circle()
                .fill(tintColor)
                .frame(width: dotSize, height: dotSize)
            line(visible: showBottomLine)
        }
    }

    private func line(visible: Bool) -> some View {
        Rectangle()
            .fill(visible ? Color.Semantic.secondaryText.opacity(Opacity.disabled) : Color.clear)
            .frame(width: lineWidth)
            .frame(maxHeight: .infinity)
    }
}

#Preview {
    VStack(spacing: 0) {
        ForEach(0 ..< 4) { i in
            HStack(spacing: Spacing.s) {
                TimelineTrack(
                    tintColor: .blue,
                    showTopLine: i != 0,
                    showBottomLine: i != 3
                )
                Text("Item \(i)")
                Spacer()
            }
            .frame(height: 60)
        }
    }
    .padding()
}
