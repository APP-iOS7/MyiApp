import DesignSystem
import Domain
import SwiftUI

struct StatisticCard: View {
    let title: String
    let image: Image
    let tintColor: Color
    let metrics: [StatisticMetric]
    var showsChevron: Bool = false

    var body: some View {
        SectionCard(spacing: Spacing.s) {
            header
            ForEach(metrics) { metricRow($0) }
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
            if showsChevron {
                RowChevron()
            }
        }
    }

    private func metricRow(_ metric: StatisticMetric) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(metric.currentText)
                .font(.subheadline)
                .foregroundColor(.Semantic.secondaryText)

            ZStack(alignment: .leading) {
                ProgressBar(ratio: metric.currentRatio, tintColor: tintColor)
                ProgressBarMarker(ratio: metric.previousRatio)
            }

            ProgressBarMarkerLabel(ratio: metric.previousRatio, text: metric.previousText)
        }
    }
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
                StatisticMetric(currentText: "시간 45분", previousText: "어제 30분", current: 45, previous: 30)
            ]
        )
        StatisticCard(
            title: "배변 기록 분석",
            image: Image(Asset.Records.Color.potty),
            tintColor: .Semantic.potty,
            metrics: [
                StatisticMetric(currentText: "소변 5회", previousText: "어제 4회", current: 5, previous: 4),
                StatisticMetric(currentText: "대변 2회", previousText: "어제 3회", current: 2, previous: 3)
            ]
        )
    }
    .padding()
    .background(Color(Asset.Tokens.gray400))
}
