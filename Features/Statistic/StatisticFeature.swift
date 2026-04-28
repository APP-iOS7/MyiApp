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
            self.selectedCategories = Set(CareEvent.Category.statisticFilterCases)
        }

        // MARK: - 집계 (Derived State)

        var previousDate: Date {
            Calendar.current.date(byAdding: .day, value: -mode.stepDays, to: selectedDate) ?? selectedDate
        }

        // 수유
        var feedingCount: Int { CareRecordAggregator.feedingCount(in: records, on: selectedDate) }
        var previousFeedingCount: Int { CareRecordAggregator.feedingCount(in: records, on: previousDate) }
        var totalMl: Int { CareRecordAggregator.totalMl(in: records, on: selectedDate) }
        var previousTotalMl: Int { CareRecordAggregator.totalMl(in: records, on: previousDate) }
        var breastfeedingMinutes: Int { CareRecordAggregator.totalBreastfeedingMinutes(in: records, on: selectedDate) }
        var previousBreastfeedingMinutes: Int { CareRecordAggregator.totalBreastfeedingMinutes(in: records, on: previousDate) }

        // 배변
        var potty: (pee: Int, poop: Int) { CareRecordAggregator.pottyCount(in: records, on: selectedDate) }
        var previousPotty: (pee: Int, poop: Int) { CareRecordAggregator.pottyCount(in: records, on: previousDate) }

        // 수면
        var sleepCount: Int { CareRecordAggregator.count(of: .sleep, in: records, on: selectedDate) }
        var previousSleepCount: Int { CareRecordAggregator.count(of: .sleep, in: records, on: previousDate) }
        var sleepMinutes: Int? { CareRecordAggregator.totalSleepMinutes(in: records, on: selectedDate) }
        var previousSleepMinutes: Int? { CareRecordAggregator.totalSleepMinutes(in: records, on: previousDate) }

        // 목욕
        var bathCount: Int { CareRecordAggregator.count(of: .bath, in: records, on: selectedDate) }
        var previousBathCount: Int { CareRecordAggregator.count(of: .bath, in: records, on: previousDate) }

        // 간식
        var snackCount: Int { CareRecordAggregator.count(of: .snack, in: records, on: selectedDate) }
        var previousSnackCount: Int { CareRecordAggregator.count(of: .snack, in: records, on: previousDate) }

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
    }

    @Dependency(\.careRecordClient) var careRecordClient

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .task, .binding(\.selectedDate), .binding(\.mode):
                return loadRecords(for: state)

            case let .recordsLoaded(records):
                state.records = records
                return .none

            case .recordsLoadFailed:
                state.records = []
                return .none

            case .binding:
                return .none
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
        case .daily:  1
        case .weekly: 7
        }
    }
}
