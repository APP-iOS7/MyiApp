import DesignSystem
import Domain
import SwiftUI

/// 카테고리 통계 카드. metrics 길이만큼 비교 바 행을 그린다.
struct StatisticCard: View {
    let title: String
    let image: Image
    let tintColor: Color
    let metrics: [StatisticMetric]

    var body: some View {
        SectionCard(spacing: Spacing.s) {
            header
            ForEach(metrics) { metric in
                metricRow(metric)
            }
        }
    }

    private var header: some View {
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
    }

    private func metricRow(_ metric: StatisticMetric) -> some View {
        let ratios = ratios(for: metric)
        return VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(metric.currentText)
                .font(.subheadline)
                .foregroundColor(.Semantic.secondaryText)

            ZStack(alignment: .leading) {
                ProgressBar(ratio: ratios.current, tintColor: tintColor)
                ProgressBarMarker(ratio: ratios.previous)
            }

            ProgressBarMarkerLabel(ratio: ratios.previous, text: metric.previousText)
        }
    }

    private func ratios(for metric: StatisticMetric) -> (current: CGFloat, previous: CGFloat) {
        let base = max(CGFloat(metric.current), CGFloat(metric.previous), 1)
        return (
            current: CGFloat(metric.current) / base,
            previous: CGFloat(metric.previous) / base
        )
    }
}

struct StatisticMetric: Identifiable {
    let id = UUID()
    let currentText: String
    let previousText: String
    let current: Int
    let previous: Int
}

#Preview {
    VStack(spacing: 16) {
        StatisticCard(
            title: "수유 기록 분석",
            image: Image(Asset.Records.Color.meal),
            tintColor: .Semantic.feeding,
            metrics: [
                StatisticMetric(currentText: "횟수 5회", previousText: "어제 3회", current: 5, previous: 3),
                StatisticMetric(currentText: "용량 350ml", previousText: "어제 400ml", current: 350, previous: 400),
                StatisticMetric(currentText: "시간 45분", previousText: "어제 30분", current: 45, previous: 30),
            ]
        )
        StatisticCard(
            title: "배변 기록 분석",
            image: Image(Asset.Records.Color.potty),
            tintColor: .Semantic.potty,
            metrics: [
                StatisticMetric(currentText: "소변 5회", previousText: "어제 4회", current: 5, previous: 4),
                StatisticMetric(currentText: "대변 2회", previousText: "어제 3회", current: 2, previous: 3),
            ]
        )
    }
    .padding()
}
