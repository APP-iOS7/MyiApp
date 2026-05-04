import Charts
import DesignSystem
import SwiftUI

struct GrowthEntry: Identifiable, Equatable {
    var id: TimeInterval { date.timeIntervalSince1970 }
    let date: Date
    let value: Double
}

struct GrowthLineChart: View {
    let data: [(date: Date, value: Double)]
    let startDate: Date
    let endDate: Date
    let mode: GrowthMode
    @Binding var selectedEntry: GrowthEntry?

    private var filteredEntries: [GrowthEntry] {
        data
            .filter { $0.date >= startDate && $0.date <= endDate }
            .sorted { $0.date < $1.date }
            .map { GrowthEntry(date: $0.date, value: $0.value) }
    }

    var body: some View {
        if filteredEntries.count < 2 {
            emptyView
        } else {
            chartContent
        }
    }

    private var emptyView: some View {
        Text("데이터가 부족합니다.")
            .font(.subheadline)
            .foregroundColor(.Semantic.secondaryText)
            .frame(maxWidth: .infinity, minHeight: GrowthChartLayout.emptyMinHeight)
    }

    private var chartContent: some View {
        Chart {
            dataMarks
            selectionMark
        }
        .chartXAxis { xAxisContent }
        .chartYAxis { yAxisContent }
        .chartOverlay { proxy in tapOverlay(proxy: proxy) }
        .frame(height: GrowthChartLayout.chartHeight)
    }

    @ChartContentBuilder
    private var dataMarks: some ChartContent {
        ForEach(filteredEntries) { entry in
            LineMark(
                x: .value("날짜", entry.date),
                y: .value(mode.unit, entry.value)
            )
            .foregroundStyle(Color.Semantic.primaryAction)

            PointMark(
                x: .value("날짜", entry.date),
                y: .value(mode.unit, entry.value)
            )
            .foregroundStyle(Color.Semantic.primaryAction)
            .symbolSize(selectedEntry?.date == entry.date ? GrowthChartLayout.selectedPointSize : GrowthChartLayout
                .pointSize)
        }
    }

    @ChartContentBuilder
    private var selectionMark: some ChartContent {
        if let selected = selectedEntry, filteredEntries.contains(where: { $0.date == selected.date }) {
            RuleMark(x: .value("선택", selected.date))
                .foregroundStyle(Color.Semantic.secondaryText.opacity(Opacity.disabled))
                .lineStyle(StrokeStyle(lineWidth: 1))
                .annotation(
                    position: annotationPosition(for: selected),
                    spacing: Spacing.xs,
                    overflowResolution: .init(x: .fit(to: .chart), y: .fit(to: .chart))
                ) {
                    SelectionPopup(
                        title: selected.date.formatted(.dateTime.year(.twoDigits).month().day()),
                        value: mode.formatWithUnit(selected.value)
                    )
                }
        }
    }

    @AxisContentBuilder
    private var xAxisContent: some AxisContent {
        AxisMarks(values: .automatic(desiredCount: GrowthChartLayout.axisDesiredCount)) { _ in
            AxisValueLabel(format: .dateTime.month().day())
                .font(.caption2)
                .foregroundStyle(Color.Semantic.secondaryText)
        }
    }

    @AxisContentBuilder
    private var yAxisContent: some AxisContent {
        AxisMarks(values: .automatic(desiredCount: GrowthChartLayout.axisDesiredCount)) { value in
            AxisGridLine()
                .foregroundStyle(Color.Semantic.secondaryText.opacity(Opacity.track))
            AxisValueLabel {
                if let v = value.as(Double.self) {
                    Text(mode.format(v))
                        .font(.caption2)
                        .foregroundStyle(Color.Semantic.secondaryText)
                }
            }
        }
    }

    private func tapOverlay(proxy: ChartProxy) -> some View {
        GeometryReader { _ in
            Rectangle()
                .fill(.clear)
                .contentShape(Rectangle())
                .onTapGesture { location in
                    handleTap(at: location, proxy: proxy)
                }
        }
    }

    private func handleTap(at location: CGPoint, proxy: ChartProxy) {
        guard let tappedDate: Date = proxy.value(atX: location.x) else { return }

        let closest = filteredEntries.min {
            abs($0.date.timeIntervalSince(tappedDate)) < abs($1.date.timeIntervalSince(tappedDate))
        }
        guard let closest else { return }

        withAnimation(.easeInOut(duration: GrowthChartLayout.selectionAnimationDuration)) {
            selectedEntry = selectedEntry?.date == closest.date ? nil : closest
        }
    }

    private func annotationPosition(for entry: GrowthEntry) -> AnnotationPosition {
        guard let first = filteredEntries.first, let last = filteredEntries.last else { return .top }

        let total = last.date.timeIntervalSince(first.date)
        guard total > 0 else { return .top }

        let fraction = entry.date.timeIntervalSince(first.date) / total
        return fraction > GrowthChartLayout.trailingAnnotationThreshold ? .topLeading : .topTrailing
    }
}
