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
