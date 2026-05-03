import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct GrowthChartView: View {
    @Bindable var store: StoreOf<GrowthChartFeature>

    public init(store: StoreOf<GrowthChartFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: Spacing.m) {
                Picker("성장 모드", selection: $store.mode) {
                    ForEach(GrowthMode.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
                .pickerStyle(.segmented)

                SectionCard(spacing: Spacing.m) {
                    dateRangePicker

                    GrowthLineChart(
                        data: store.data,
                        startDate: store.startDate,
                        endDate: store.endDate,
                        mode: store.mode,
                        selectedEntry: $store.selectedEntry
                    )
                }

                if let latest = store.latestEntry {
                    SectionCard(spacing: 0) {
                        SummaryRow(
                            title: "최근 측정",
                            value: store.mode.formatWithUnit(latest.value),
                            detail: latest.date.formatted(.dateTime.year(.twoDigits).month().day())
                        )
                    }
                }
            }
            .padding(Spacing.m)
        }
        .scrollIndicators(.hidden)
        .background(Color.Semantic.screenBackground.ignoresSafeArea())
        .navigationTitle("성장곡선")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var dateRangePicker: some View {
        HStack(spacing: Spacing.s) {
            BorderedDateBox(date: $store.startDate, to: store.endDate)
            Text("~").foregroundStyle(Color.Semantic.secondaryText)
            BorderedDateBox(date: $store.endDate, from: store.startDate)
        }
    }
}
