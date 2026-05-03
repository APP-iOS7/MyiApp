import ComposableArchitecture
import DesignSystem
import Domain
import Shared
import SwiftUI

public struct FoodDetailView: View {
    @Bindable var store: StoreOf<FoodDetailFeature>

    public init(store: StoreOf<FoodDetailFeature>) {
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

                    ForEach(store.feedingTrends) { trend in
                        VStack(alignment: .leading, spacing: Spacing.s) {
                            Text(trend.type.rawValue)
                                .font(.caption)
                                .foregroundStyle(Color.Semantic.secondaryText)
                            TrendBarChart(
                                entries: trend.entries,
                                unit: trend.type.unit,
                                tintColor: .Semantic.feeding
                            )
                        }
                    }
                }

                StatisticCard(
                    title: "수유/이유식 기록 분석",
                    image: Image(Asset.Records.Color.meal),
                    tintColor: .Semantic.feeding,
                    metrics: [
                        StatisticMetric(
                            currentText: "횟수 \(store.feedingCount)회",
                            previousText: "\(store.mode.previousLabel) \(store.previousFeedingCount)회",
                            current: store.feedingCount,
                            previous: store.previousFeedingCount
                        ),
                        StatisticMetric(
                            currentText: "용량 \(store.totalMl)ml",
                            previousText: "\(store.mode.previousLabel) \(store.previousTotalMl)ml",
                            current: store.totalMl,
                            previous: store.previousTotalMl
                        ),
                        StatisticMetric(
                            currentText: "시간 \(DurationFormatter.hourMinute(fromMinutes: store.breastfeedingMinutes))",
                            previousText: "\(store.mode.previousLabel) \(DurationFormatter.hourMinute(fromMinutes: store.previousBreastfeedingMinutes))",
                            current: store.breastfeedingMinutes,
                            previous: store.previousBreastfeedingMinutes
                        )
                    ]
                )
            }
            .padding(Spacing.m)
        }
        .scrollIndicators(.hidden)
        .background(Color.Semantic.screenBackground.ignoresSafeArea())
        .navigationTitle("수유/이유식 기록 분석")
        .navigationBarTitleDisplayMode(.inline)
        .task { await store.send(.view(.task)).finish() }
    }

    private var dateNavigatorStep: DateNavigator.Step {
        switch store.mode {
        case .daily: .days(1)
        case .weekly: .days(7)
        case .monthly: .month
        }
    }
}
