import ComposableArchitecture
import DesignSystem
import Domain
import Shared
import SwiftUI

public struct StatisticView: View {
    @Bindable var store: StoreOf<StatisticFeature>

    public init(store: StoreOf<StatisticFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ScrollView {
                VStack(spacing: Spacing.m) {
                    ScreenTitle("기록 분석") {
                        Button("성장 차트", systemImage: "chart.xyaxis.line") { store.send(.growthChartButtonTapped) }
                            .labelStyle(.iconOnly)
                    }
                    overviewCard
                    statisticCards
                }
                .padding(Spacing.m)
            }
            .scrollIndicators(.hidden)
            .background(Color.Semantic.screenBackground.ignoresSafeArea())
            .task { await store.send(.task).finish() }
        } destination: { store in
            switch store.case {
            case let .growthChart(store):
                GrowthChartView(store: store)
            case let .snackDetail(store):
                SnackDetailView(store: store)
            }
        }
    }
}

// MARK: - Overview

extension StatisticView {
    private var overviewCard: some View {
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

// MARK: - Statistic Cards

extension StatisticView {
    private var statisticCards: some View {
        VStack(spacing: Spacing.m) {
            StatisticCard(
                title: "수유/이유식 기록 분석",
                image: Image(Asset.Records.Color.meal),
                tintColor: .Semantic.feeding,
                metrics: [
                    countMetric(title: "횟수", current: store.feedingCount, previous: store.previousFeedingCount),
                    valueMetric(title: "용량", current: store.totalMl, previous: store.previousTotalMl, unit: "ml"),
                    minutesMetric(
                        title: "시간",
                        current: store.breastfeedingMinutes,
                        previous: store.previousBreastfeedingMinutes
                    )
                ]
            )

            StatisticCard(
                title: "배변 기록 분석",
                image: Image(Asset.Records.Color.potty),
                tintColor: .Semantic.potty,
                metrics: [
                    countMetric(title: "소변", current: store.potty.pee, previous: store.previousPotty.pee),
                    countMetric(title: "대변", current: store.potty.poop, previous: store.previousPotty.poop)
                ]
            )

            StatisticCard(
                title: "수면 기록 분석",
                image: Image(Asset.Records.Color.sleep),
                tintColor: .Semantic.sleep,
                metrics: [
                    countMetric(title: "횟수", current: store.sleepCount, previous: store.previousSleepCount),
                    minutesMetric(title: "시간", current: store.sleepMinutes, previous: store.previousSleepMinutes)
                ]
            )

            StatisticCard(
                title: "목욕 기록 분석",
                image: Image(Asset.Records.Color.bath),
                tintColor: .Semantic.bath,
                metrics: [
                    countMetric(title: "횟수", current: store.bathCount, previous: store.previousBathCount)
                ]
            )

            NavigationLink(state: StatisticFeature.Path.State.snackDetail(
                SnackDetailFeature.State(baby: store.baby, selectedDate: store.selectedDate, mode: store.mode)
            )) {
                StatisticCard(
                    title: "간식 기록 분석",
                    image: Image(Asset.Records.Color.snack),
                    tintColor: .Semantic.snack,
                    metrics: [
                        countMetric(title: "횟수", current: store.snackCount, previous: store.previousSnackCount)
                    ]
                )
            }
            .buttonStyle(NoHighlightButtonStyle())
        }
    }

    private var previousLabel: String {
        switch store.mode {
        case .daily: "어제"
        case .weekly: "지난주"
        }
    }

    private func countMetric(title: String, current: Int, previous: Int) -> StatisticMetric {
        valueMetric(title: title, current: current, previous: previous, unit: "회")
    }

    private func valueMetric(title: String, current: Int, previous: Int, unit: String) -> StatisticMetric {
        StatisticMetric(
            currentText: "\(title) \(current)\(unit)",
            previousText: "\(previousLabel) \(previous)\(unit)",
            current: current,
            previous: previous
        )
    }

    private func minutesMetric(title: String, current: Int, previous: Int) -> StatisticMetric {
        StatisticMetric(
            currentText: "\(title) \(DurationFormatter.hourMinute(fromMinutes: current))",
            previousText: "\(previousLabel) \(DurationFormatter.hourMinute(fromMinutes: previous))",
            current: current,
            previous: previous
        )
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

#Preview("기록 없음") {
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
