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
                        ForEach(StatisticFeature.Mode.allCases, id: \.self) { mode in
                            Text(mode.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)

                    DateNavigator(
                        selectedDate: $store.selectedDate,
                        step: .days(store.mode.stepDays),
                        labelText: dateLabel(for:)
                    )
                }

                SectionCard(spacing: 0) {
                    SummaryRow(
                        title: "이번 \(store.mode.rawValue)",
                        value: "\(store.count)회",
                        detail: "지난 \(store.mode.rawValue) \(store.previousCount)회"
                    )
                }
            }
            .padding(Spacing.m)
        }
        .scrollIndicators(.hidden)
        .background(Color.Semantic.screenBackground.ignoresSafeArea())
        .navigationTitle("간식 기록 분석")
        .navigationBarTitleDisplayMode(.inline)
        .task { await store.send(.task).finish() }
    }

    private func dateLabel(for date: Date) -> String {
        switch store.mode {
        case .daily: date.shortDateWithDayLabel()
        case .weekly: date.weekRangeLabel()
        }
    }
}
