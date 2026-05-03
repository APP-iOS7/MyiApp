import ComposableArchitecture
import DesignSystem
import Domain
import Shared
import SwiftUI

public struct SnackDetailView: View {
    @Bindable var store: StoreOf<SnackDetailFeature>

    public init(store: StoreOf<SnackDetailFeature>) {
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

                    TrendBarChart(
                        entries: store.trendEntries,
                        unit: "회",
                        tintColor: .Semantic.snack
                    )
                }

                StatisticCard(
                    title: "간식 기록 분석",
                    image: Image(Asset.Records.Color.snack),
                    tintColor: .Semantic.snack,
                    metrics: [
                        StatisticMetric(
                            currentText: "이번 \(store.mode.rawValue) \(store.count)회",
                            previousText: "\(store.mode.previousLabel) \(store.previousCount)회",
                            current: store.count,
                            previous: store.previousCount
                        )
                    ]
                )
            }
            .padding(Spacing.m)
        }
        .scrollIndicators(.hidden)
        .background(Color.Semantic.screenBackground.ignoresSafeArea())
        .navigationTitle("간식 기록 분석")
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
