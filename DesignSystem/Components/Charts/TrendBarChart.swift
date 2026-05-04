import Charts
import SwiftUI

public struct TrendBarChart: View {
    public struct Entry: Identifiable, Equatable {
        public let id: Date
        public let label: String
        public let value: Double

        public init(id: Date, label: String, value: Double) {
            self.id = id
            self.label = label
            self.value = value
        }
    }

    public let entries: [Entry]
    public let unit: String
    public let tintColor: Color
    public let valueFormatter: (Double) -> String

    public init(
        entries: [Entry],
        unit: String,
        tintColor: Color,
        valueFormatter: @escaping (Double) -> String = { String(Int($0.rounded())) }
    ) {
        self.entries = entries
        self.unit = unit
        self.tintColor = tintColor
        self.valueFormatter = valueFormatter
    }

    private var average: Double {
        guard !entries.isEmpty else { return 0 }

        return entries.reduce(0) { $0 + $1.value } / Double(entries.count)
    }

    public var body: some View {
        Chart {
            ForEach(entries) { entry in
                BarMark(
                    x: .value("기간", entry.label),
                    y: .value(unit, entry.value)
                )
                .foregroundStyle(tintColor)
                .annotation(position: .top) {
                    Text("\(valueFormatter(entry.value))\(unit)")
                        .font(.caption2)
                        .foregroundStyle(Color.Semantic.secondaryText)
                }
            }

            if average > 0 {
                RuleMark(y: .value("평균", average))
                    .foregroundStyle(Color.Semantic.secondaryText.opacity(Opacity.disabled))
                    .lineStyle(StrokeStyle(
                        lineWidth: TrendBarChartLayout.averageLineWidth,
                        dash: TrendBarChartLayout.averageLineDash
                    ))
                    .annotation(position: .top, alignment: .trailing) {
                        Text("평균 \(valueFormatter(average))\(unit)")
                            .font(.caption2)
                            .foregroundStyle(Color.Semantic.secondaryText)
                    }
            }
        }
        .chartYAxis(.hidden)
        .frame(height: TrendBarChartLayout.chartHeight)
    }
}

#Preview {
    VStack(spacing: 24) {
        TrendBarChart(
            entries: (0 ..< 7).map { i in
                TrendBarChart.Entry(
                    id: Calendar.current.date(byAdding: .day, value: -i, to: Date()) ?? Date(),
                    label: "\(i + 1)",
                    value: Double.random(in: 0 ... 5)
                )
            }.reversed(),
            unit: "회",
            tintColor: .Semantic.snack
        )
        .padding()
    }
}
