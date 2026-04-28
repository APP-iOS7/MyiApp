import DesignSystem
import Domain
import SwiftUI

/// 개별 카테고리 통계 카드 (횟수 + 비교 바 + 선택적 용량/시간)
struct StatisticCard: View {
    let title: String
    let image: Image
    let tintColor: Color
    let count: Int
    let previousCount: Int
    let amount: Int?
    let previousAmount: Int?
    let minutes: Int?
    let previousMinutes: Int?
    let previousLabel: String

    var body: some View {
        SectionCard(spacing: Spacing.s) {
            // 헤더
            HStack {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: IconSize.l, height: IconSize.l)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }

            // 횟수
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("횟수 \(count)회")
                    .font(.subheadline)
                    .foregroundColor(.Semantic.secondaryText)
                ProgressComparisonBar(
                    current: count, previous: previousCount,
                    tintColor: tintColor, unit: "회",
                    previousLabel: previousLabel
                )
            }

            // 용량 (수유 전용)
            if let amount, let prevAmount = previousAmount {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("용량 \(amount)ml")
                        .font(.subheadline)
                        .foregroundColor(.Semantic.secondaryText)
                    ProgressComparisonBar(
                        current: amount, previous: prevAmount,
                        tintColor: tintColor, unit: "ml",
                        previousLabel: previousLabel
                    )
                }
            }

            // 시간 (수유/수면 전용)
            if let minutes, let prevMinutes = previousMinutes {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("시간 \(formattedTime(minutes))")
                        .font(.subheadline)
                        .foregroundColor(.Semantic.secondaryText)
                    ProgressComparisonBar(
                        current: minutes, previous: prevMinutes,
                        tintColor: tintColor, unit: "분",
                        previousLabel: previousLabel
                    )
                }
            }
        }
    }

    private func formattedTime(_ totalMinutes: Int) -> String {
        let h = totalMinutes / 60
        let m = totalMinutes % 60
        return h > 0 ? "\(h)시간 \(m)분" : "\(m)분"
    }
}

/// 배변 전용 통계 카드 (소변 + 대변 분리)
struct PottyStatisticCard: View {
    let peeCount: Int
    let previousPeeCount: Int
    let poopCount: Int
    let previousPoopCount: Int
    let previousLabel: String

    var body: some View {
        SectionCard(spacing: Spacing.s) {
            HStack {
                Image(Asset.Records.Color.potty)
                    .resizable()
                    .scaledToFit()
                    .frame(width: IconSize.l, height: IconSize.l)
                Text("배변 기록 분석")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("소변 \(peeCount)회")
                    .font(.subheadline)
                    .foregroundColor(.Semantic.secondaryText)
                ProgressComparisonBar(
                    current: peeCount, previous: previousPeeCount,
                    tintColor: .Semantic.potty, unit: "회",
                    previousLabel: previousLabel
                )
            }

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("대변 \(poopCount)회")
                    .font(.subheadline)
                    .foregroundColor(.Semantic.secondaryText)
                ProgressComparisonBar(
                    current: poopCount, previous: previousPoopCount,
                    tintColor: .Semantic.potty, unit: "회",
                    previousLabel: previousLabel
                )
            }
        }
    }
}

#Preview("StatisticCard") {
    VStack(spacing: 16) {
        StatisticCard(
            title: "분유/수유/이유식 기록 분석",
            image: Image(Asset.Records.Color.meal),
            tintColor: .Semantic.feeding,
            count: 5, previousCount: 3,
            amount: 350, previousAmount: 400,
            minutes: 45, previousMinutes: 30,
            previousLabel: "어제"
        )
        PottyStatisticCard(
            peeCount: 5, previousPeeCount: 4,
            poopCount: 2, previousPoopCount: 3,
            previousLabel: "어제"
        )
    }
    .padding()
}
