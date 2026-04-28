import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct StatisticView: View {
    @Bindable var store: StoreOf<StatisticFeature>

    public init(store: StoreOf<StatisticFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: Spacing.m) {
                overviewCard
                statisticCards
            }
            .padding(Spacing.m)
        }
        .background(Color.Semantic.screenBackground.ignoresSafeArea())
        .task { await store.send(.task).finish() }
    }
}

// MARK: - Overview

extension StatisticView {
    private var overviewCard: some View {
        SectionCard(spacing: Spacing.m) {
            Picker("모드 선택", selection: $store.mode) {
                ForEach(StatisticMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue)
                }
            }
            .pickerStyle(.segmented)

            DateNavigator(
                selectedDate: $store.selectedDate,
                stepDays: store.mode.stepDays,
                labelText: dateLabel(for:)
            )

            CategoryFilterGrid(selectedCategories: $store.selectedCategories)

            switch store.mode {
            case .daily:
                DailyChartView(
                    baby: store.baby,
                    records: store.records,
                    selectedDate: store.selectedDate,
                    selectedCategories: store.selectedCategories
                )

            case .weekly:
                WeeklyChartView(
                    baby: store.baby,
                    records: store.records,
                    selectedDate: store.selectedDate,
                    selectedCategories: store.selectedCategories
                )
            }

            Text(store.babySummaryText)
                .font(.subheadline)
                .foregroundColor(.Semantic.secondaryText)
                .frame(maxWidth: .infinity)
        }
    }

    private func dateLabel(for date: Date) -> String {
        switch store.mode {
        case .daily:
            date.shortDateWithDayLabel()
        case .weekly:
            date.weekRangeLabel()
        }
    }
}

private func previewBaby() -> Baby {
    Baby(
        id: UUID(),
        name: "꼬미",
        birthDate: Calendar.current.date(byAdding: .day, value: -100, to: Date())!,
        gender: .female,
        bloodType: .a,
        mainCaregiverID: "user-123"
    )
}

#Preview("기록 있음") {
    NavigationStack {
        StatisticView(
            store: Store(
                initialState: StatisticFeature.State(
                    baby: previewBaby(),
                    records: CareRecord.mocks
                )
            ) {
                StatisticFeature()
            }
        )
    }
}

#Preview("기록 없음") {
    NavigationStack {
        StatisticView(
            store: Store(
                initialState: StatisticFeature.State(
                    baby: previewBaby(),
                    records: []
                )
            ) {
                StatisticFeature()
            }
        )
    }
}

// MARK: - Statistic Cards

extension StatisticView {
    private var statisticCards: some View {
        VStack(spacing: Spacing.m) {
            // 수유/이유식
            if store.selectedCategories.contains(.feeding) {
                StatisticCard(
                    title: "수유/이유식 기록 분석",
                    image: Image(Asset.Records.Color.meal),
                    tintColor: .Semantic.feeding,
                    count: store.feedingCount,
                    previousCount: store.previousFeedingCount,
                    amount: store.totalMl,
                    previousAmount: store.previousTotalMl,
                    minutes: store.breastfeedingMinutes,
                    previousMinutes: store.previousBreastfeedingMinutes,
                    previousLabel: store.previousLabel
                )
            }

            // 배변
            if store.selectedCategories.contains(.potty) {
                PottyStatisticCard(
                    peeCount: store.potty.pee,
                    previousPeeCount: store.previousPotty.pee,
                    poopCount: store.potty.poop,
                    previousPoopCount: store.previousPotty.poop,
                    previousLabel: store.previousLabel
                )
            }

            // 수면
            if store.selectedCategories.contains(.sleep) {
                StatisticCard(
                    title: "수면 기록 분석",
                    image: Image(Asset.Records.Color.sleep),
                    tintColor: .Semantic.sleep,
                    count: store.sleepCount,
                    previousCount: store.previousSleepCount,
                    amount: nil,
                    previousAmount: nil,
                    minutes: store.sleepMinutes,
                    previousMinutes: store.previousSleepMinutes,
                    previousLabel: store.previousLabel
                )
            }

            // 목욕
            if store.selectedCategories.contains(.bath) {
                StatisticCard(
                    title: "목욕 기록 분석",
                    image: Image(Asset.Records.Color.bath),
                    tintColor: .Semantic.bath,
                    count: store.bathCount,
                    previousCount: store.previousBathCount,
                    amount: nil,
                    previousAmount: nil,
                    minutes: nil,
                    previousMinutes: nil,
                    previousLabel: store.previousLabel
                )
            }

            // 간식
            if store.selectedCategories.contains(.snack) {
                StatisticCard(
                    title: "간식 기록 분석",
                    image: Image(Asset.Records.Color.snack),
                    tintColor: .Semantic.snack,
                    count: store.snackCount,
                    previousCount: store.previousSnackCount,
                    amount: nil,
                    previousAmount: nil,
                    minutes: nil,
                    previousMinutes: nil,
                    previousLabel: store.previousLabel
                )
            }
        }
    }
}
