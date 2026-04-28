import SwiftUI

/// 오늘 vs 어제(지난주) 비교 프로그레스 바
public struct ProgressComparisonBar: View {
    public let current: Int?
    public let previous: Int?
    public let tintColor: Color
    public let unit: String
    public let previousLabel: String

    public init(
        current: Int?,
        previous: Int?,
        tintColor: Color,
        unit: String,
        previousLabel: String = "어제"
    ) {
        self.current = current
        self.previous = previous
        self.tintColor = tintColor
        self.unit = unit
        self.previousLabel = previousLabel
    }

    public var body: some View {
        GeometryReader { geometry in
            let barHeight: CGFloat = 6
            let maxWidth = geometry.size.width
            let (currentRatio, previousRatio) = ratios

            ZStack(alignment: .leading) {
                // 배경
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.gray.opacity(0.12))
                    .frame(height: barHeight)

                // 현재 값 바
                RoundedRectangle(cornerRadius: 3)
                    .fill(tintColor)
                    .frame(width: currentRatio * maxWidth, height: barHeight)

                // 이전 값 마커
                Rectangle()
                    .fill(Color.gray.opacity(0.6))
                    .frame(width: 1, height: barHeight + 4)
                    .offset(x: previousRatio * maxWidth)

                // 이전 값 라벨
                if let prev = previous {
                    Text("\(previousLabel) \(prev)\(unit)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .offset(
                            x: min(previousRatio * maxWidth + 4, maxWidth - 60),
                            y: 10
                        )
                }
            }
        }
        .frame(height: 20)
    }

    private var ratios: (CGFloat, CGFloat) {
        guard let c = current, let p = previous else { return (0, 0) }
        let base = max(CGFloat(c), CGFloat(p), 1)
        return (CGFloat(c) / base, CGFloat(p) / base)
    }
}

#Preview {
    VStack(spacing: 16) {
        ProgressComparisonBar(
            current: 5, previous: 3,
            tintColor: .blue, unit: "회",
            previousLabel: "어제"
        )
        ProgressComparisonBar(
            current: 120, previous: 180,
            tintColor: .orange, unit: "ml",
            previousLabel: "지난주"
        )
        ProgressComparisonBar(
            current: nil, previous: nil,
            tintColor: .green, unit: "분"
        )
    }
    .padding()
}
