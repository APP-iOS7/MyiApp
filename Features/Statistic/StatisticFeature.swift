import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct StatisticFeature {
    @ObservableState
    public struct State: Equatable {
        public var baby: Baby
        public var records: [CareRecord]
        public var selectedDate: Date
        public var mode: StatisticMode
        public var selectedCategories: Set<CareEvent.Category>

        public init(
            baby: Baby,
            records: [CareRecord] = [],
            selectedDate: Date = Date(),
            mode: StatisticMode = .daily
        ) {
            self.baby = baby
            self.records = records
            self.selectedDate = selectedDate
            self.mode = mode
            selectedCategories = Set(CareEvent.Category.statisticFilterCases)
        }

        // MARK: - 집계 (Derived State)

        var previousDate: Date {
            Calendar.current.date(byAdding: .day, value: -mode.stepDays, to: selectedDate) ?? selectedDate
        }

        // 수유
        var feedingCount: Int {
            records.filter { $0.event.category == .feeding && Calendar.current.isDate($0.createdAt, inSameDayAs: selectedDate) }.count
        }
        var previousFeedingCount: Int {
            records.filter { $0.event.category == .feeding && Calendar.current.isDate($0.createdAt, inSameDayAs: previousDate) }.count
        }
        var totalMl: Int {
            records
                .filter { Calendar.current.isDate($0.createdAt, inSameDayAs: selectedDate) }
                .reduce(0) { total, record in
                    switch record.event {
                    case let .formula(ml), let .babyFood(ml), let .pumpedMilk(ml): return total + ml
                    default: return total
                    }
                }
        }
        var previousTotalMl: Int {
            records
                .filter { Calendar.current.isDate($0.createdAt, inSameDayAs: previousDate) }
                .reduce(0) { total, record in
                    switch record.event {
                    case let .formula(ml), let .babyFood(ml), let .pumpedMilk(ml): return total + ml
                    default: return total
                    }
                }
        }
        var breastfeedingMinutes: Int {
            records
                .filter { Calendar.current.isDate($0.createdAt, inSameDayAs: selectedDate) }
                .reduce(0) { total, record in
                    if case let .breastfeeding(left, right) = record.event { return total + left + right }
                    return total
                }
        }
        var previousBreastfeedingMinutes: Int {
            records
                .filter { Calendar.current.isDate($0.createdAt, inSameDayAs: previousDate) }
                .reduce(0) { total, record in
                    if case let .breastfeeding(left, right) = record.event { return total + left + right }
                    return total
                }
        }

        // 배변
        var potty: (pee: Int, poop: Int) {
            var pee = 0, poop = 0
            for record in records where Calendar.current.isDate(record.createdAt, inSameDayAs: selectedDate) {
                switch record.event {
                case .pee: pee += 1
                case .poop: poop += 1
                case .pottyAll: pee += 1; poop += 1
                default: break
                }
            }
            return (pee, poop)
        }
        var previousPotty: (pee: Int, poop: Int) {
            var pee = 0, poop = 0
            for record in records where Calendar.current.isDate(record.createdAt, inSameDayAs: previousDate) {
                switch record.event {
                case .pee: pee += 1
                case .poop: poop += 1
                case .pottyAll: pee += 1; poop += 1
                default: break
                }
            }
            return (pee, poop)
        }

        // 수면
        var sleepCount: Int {
            records.filter { $0.event.category == .sleep && Calendar.current.isDate($0.createdAt, inSameDayAs: selectedDate) }.count
        }
        var previousSleepCount: Int {
            records.filter { $0.event.category == .sleep && Calendar.current.isDate($0.createdAt, inSameDayAs: previousDate) }.count
        }
        var sleepMinutes: Int {
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: selectedDate)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
            return records.reduce(0) { total, record in
                guard case let .sleep(start, end) = record.event, let end else { return total }
                let clipped = max(start, startOfDay)
                let clippedEnd = min(end, endOfDay)
                let interval = clippedEnd.timeIntervalSince(clipped)
                return interval > 0 ? total + Int(interval / 60) : total
            }
        }
        var previousSleepMinutes: Int {
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: previousDate)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
            return records.reduce(0) { total, record in
                guard case let .sleep(start, end) = record.event, let end else { return total }
                let clipped = max(start, startOfDay)
                let clippedEnd = min(end, endOfDay)
                let interval = clippedEnd.timeIntervalSince(clipped)
                return interval > 0 ? total + Int(interval / 60) : total
            }
        }

        // 목욕
        var bathCount: Int {
            records.filter { $0.event.category == .bath && Calendar.current.isDate($0.createdAt, inSameDayAs: selectedDate) }.count
        }
        var previousBathCount: Int {
            records.filter { $0.event.category == .bath && Calendar.current.isDate($0.createdAt, inSameDayAs: previousDate) }.count
        }

        // 간식
        var snackCount: Int {
            records.filter { $0.event.category == .snack && Calendar.current.isDate($0.createdAt, inSameDayAs: selectedDate) }.count
        }
        var previousSnackCount: Int {
            records.filter { $0.event.category == .snack && Calendar.current.isDate($0.createdAt, inSameDayAs: previousDate) }.count
        }

        // 성장
        public var growthRecords: [CareRecord] = []
        @Presents public var growthChart: GrowthChartFeature.State?

        var babySummaryText: String {
            let genderText = baby.gender == .female ? "여" : "남"
            let days = Calendar.current.dateComponents([.day], from: baby.birthDate, to: Date()).day ?? 0
            return "\(baby.name) · \(genderText) · 태어난지 \(days + 1)일"
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case task
        case recordsLoaded([CareRecord])
        case recordsLoadFailed(CareRecordError)
        case growthRecordsLoaded([CareRecord])
        case growthChartButtonTapped
        case growthChart(PresentationAction<GrowthChartFeature.Action>)
    }

    @Dependency(\.careRecordClient) var careRecordClient

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .task:
                return .merge(
                    loadRecords(for: state),
                    loadGrowthRecords(for: state)
                )

            case .binding(\.mode), .binding(\.selectedDate):
                return loadRecords(for: state)

            case let .recordsLoaded(records):
                state.records = records
                return .none

            case .recordsLoadFailed:
                state.records = []
                return .none

            case let .growthRecordsLoaded(records):
                state.growthRecords = records.filter { $0.event.category == .growth }
                return .none

            case .growthChartButtonTapped:
                state.growthChart = GrowthChartFeature.State(records: state.growthRecords, baby: state.baby)
                return .none

            case .growthChart:
                return .none

            case .binding:
                return .none
            }
        }
        .ifLet(\.$growthChart, action: \.growthChart) {
            GrowthChartFeature()
        }
    }

    private func loadGrowthRecords(for state: State) -> Effect<Action> {
        let babyID = state.baby.id
        let start = state.baby.birthDate
        let calendar = Calendar.current
        guard let end = calendar.date(byAdding: .day, value: 1, to: Date()) else { return .none }

        return .run { [careRecordClient] send in
            do throws(CareRecordError) {
                let records = try await careRecordClient.loadRecords(babyID, start ..< end)
                await send(.growthRecordsLoaded(records))
            } catch {
                // 성장 기록은 non-critical — 조용히 무시
            }
        }
    }

    private func loadRecords(for state: State) -> Effect<Action> {
        let babyID = state.baby.id
        let cal = Calendar.current
        let dayStart = cal.startOfDay(for: state.selectedDate)
        guard let start = cal.date(byAdding: .day, value: -state.mode.stepDays, to: dayStart),
              let end = cal.date(byAdding: .day, value: 1, to: dayStart)
        else { return .none }

        return .run { [careRecordClient] send in
            do throws(CareRecordError) {
                let records = try await careRecordClient.loadRecords(babyID, start ..< end)
                await send(.recordsLoaded(records))
            } catch {
                await send(.recordsLoadFailed(error))
            }
        }
    }
}

// TODO: -  코드 더럽다
extension CareEvent.Category {
    /// 통계 화면 필터 그리드에 노출할 카테고리 (vital/medical/growth은 제외)
    static let statisticFilterCases: [CareEvent.Category] = [.feeding, .potty, .sleep, .bath, .snack]
}

/// 통계 화면 일/주 모드
public enum StatisticMode: String, CaseIterable, Hashable, Sendable {
    case daily = "일"
    case weekly = "주"

    public var stepDays: Int {
        switch self {
        case .daily: 1
        case .weekly: 7
        }
    }
}
