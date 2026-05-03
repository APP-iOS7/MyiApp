import ComposableArchitecture
import DesignSystem
import Domain
import Shared
import SwiftUI

public struct SleepDetailView: View {
    @Bindable var store: StoreOf<SleepDetailFeature>

    public init(store: StoreOf<SleepDetailFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: Spacing.m) {
                SectionCard(spacing: Spacing.m) {
                    Picker("모드 선택", selection: $store.mode) {
                        ForEach(DetailMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)

                    DateNavigator(
                        selectedDate: $store.selectedDate,
                        step: dateNavigatorStep,
                        labelText: store.mode.dateLabel(for:)
                    )
                }

                SectionCard(spacing: Spacing.m) {
                    Text(store.comparisonMessage)
                        .font(.subheadline)
                        .foregroundStyle(Color.Semantic.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: Spacing.s) {
                        Text("횟수")
                            .font(.caption)
                            .foregroundStyle(Color.Semantic.secondaryText)
                        TrendBarChart(
                            entries: store.countTrend,
                            unit: "회",
                            tintColor: .Semantic.sleep
                        )
                    }

                    VStack(alignment: .leading, spacing: Spacing.s) {
                        Text("시간")
                            .font(.caption)
                            .foregroundStyle(Color.Semantic.secondaryText)
                        TrendBarChart(
                            entries: store.minutesTrend,
                            unit: "분",
                            tintColor: .Semantic.sleep
                        )
                    }
                }

                StatisticCard(
                    title: "수면 기록 분석",
                    image: Image(Asset.Records.Color.sleep),
                    tintColor: .Semantic.sleep,
                    metrics: [
                        StatisticMetric(
                            currentText: "횟수 \(store.count)회",
                            previousText: "\(store.mode.previousLabel) \(store.previousCount)회",
                            current: store.count,
                            previous: store.previousCount
                        ),
                        StatisticMetric(
                            currentText: "시간 \(DurationFormatter.hourMinute(fromMinutes: store.minutes))",
                            previousText: "\(store.mode.previousLabel) \(DurationFormatter.hourMinute(fromMinutes: store.previousMinutes))",
                            current: store.minutes,
                            previous: store.previousMinutes
                        )
                    ]
                )
            }
            .padding(Spacing.m)
        }
        .scrollIndicators(.hidden)
        .background(Color.Semantic.screenBackground.ignoresSafeArea())
        .navigationTitle("수면 기록 분석")
        .navigationBarTitleDisplayMode(.inline)
        .task { await store.send(.task).finish() }
    }

    private var dateNavigatorStep: DateNavigator.Step {
        switch store.mode {
        case .daily: .days(1)
        case .weekly: .days(7)
        case .monthly: .month
        }
    }
}
