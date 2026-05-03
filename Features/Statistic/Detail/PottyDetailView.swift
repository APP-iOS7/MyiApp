import ComposableArchitecture
import DesignSystem
import Domain
import Shared
import SwiftUI

public struct PottyDetailView: View {
    @Bindable var store: StoreOf<PottyDetailFeature>

    public init(store: StoreOf<PottyDetailFeature>) {
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
                        Text("소변")
                            .font(.caption)
                            .foregroundStyle(Color.Semantic.secondaryText)
                        TrendBarChart(
                            entries: store.peeTrend,
                            unit: "회",
                            tintColor: .Semantic.potty
                        )
                    }

                    VStack(alignment: .leading, spacing: Spacing.s) {
                        Text("대변")
                            .font(.caption)
                            .foregroundStyle(Color.Semantic.secondaryText)
                        TrendBarChart(
                            entries: store.poopTrend,
                            unit: "회",
                            tintColor: .Semantic.potty
                        )
                    }
                }

                StatisticCard(
                    title: "배변 기록 분석",
                    image: Image(Asset.Records.Color.potty),
                    tintColor: .Semantic.potty,
                    metrics: [
                        StatisticMetric(
                            currentText: "소변 \(store.current.pee)회",
                            previousText: "\(store.mode.previousLabel) \(store.previous.pee)회",
                            current: store.current.pee,
                            previous: store.previous.pee
                        ),
                        StatisticMetric(
                            currentText: "대변 \(store.current.poop)회",
                            previousText: "\(store.mode.previousLabel) \(store.previous.poop)회",
                            current: store.current.poop,
                            previous: store.previous.poop
                        )
                    ]
                )
            }
            .padding(Spacing.m)
        }
        .scrollIndicators(.hidden)
        .background(Color.Semantic.screenBackground.ignoresSafeArea())
        .navigationTitle("배변 기록 분석")
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
