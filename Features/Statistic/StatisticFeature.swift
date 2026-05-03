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
        public var mode: Mode
        public var selectedCategories: Set<CareEvent.Category>

        public init(
            baby: Baby,
            records: [CareRecord] = [],
            selectedDate: Date = Date(),
            mode: Mode = .daily
        ) {
            self.baby = baby
            self.records = records
            self.selectedDate = selectedDate
            self.mode = mode
            selectedCategories = Set(CareEvent.Category.statisticFilterCases)
        }

        public var path = StackState<Path.State>()

        // MARK: - 집계 (Derived State)

        var previousDate: Date {
            Calendar.current.date(byAdding: .day, value: -mode.stepDays, to: selectedDate) ?? selectedDate
        }

        private var dailyRecords: [CareRecord] { records.filtered(on: selectedDate) }
        private var previousDailyRecords: [CareRecord] { records.filtered(on: previousDate) }

        // 수유
        var feedingCount: Int { dailyRecords.count(of: .feeding) }
        var previousFeedingCount: Int { previousDailyRecords.count(of: .feeding) }
        var totalMl: Int { dailyRecords.totalMl }
        var previousTotalMl: Int { previousDailyRecords.totalMl }
        var breastfeedingMinutes: Int { dailyRecords.totalBreastfeedingMinutes }
        var previousBreastfeedingMinutes: Int { previousDailyRecords.totalBreastfeedingMinutes }

        // 배변
        var potty: (pee: Int, poop: Int) { dailyRecords.pottyCount }
        var previousPotty: (pee: Int, poop: Int) { previousDailyRecords.pottyCount }

        // 수면
        var sleepCount: Int { dailyRecords.count(of: .sleep) }
        var previousSleepCount: Int { previousDailyRecords.count(of: .sleep) }
        var sleepMinutes: Int { records.totalSleepMinutes(on: selectedDate) }
        var previousSleepMinutes: Int { records.totalSleepMinutes(on: previousDate) }

        // 목욕
        var bathCount: Int { dailyRecords.count(of: .bath) }
        var previousBathCount: Int { previousDailyRecords.count(of: .bath) }

        // 간식
        var snackCount: Int { dailyRecords.count(of: .snack) }
        var previousSnackCount: Int { previousDailyRecords.count(of: .snack) }

        /// 성장
        public var growthRecords: [CareRecord] = []

        var babySummaryText: String {
            let genderText = baby.gender == .female ? "여" : "남"
            let days = Calendar.current.dateComponents([.day], from: baby.birthDate, to: Date()).day ?? 0
            return "\(baby.name) · \(genderText) · 태어난지 \(days + 1)일"
        }
    }

    public enum Action: BindableAction {
        public enum InternalAction {
            case recordsLoaded([CareRecord])
            case recordsLoadFailed(CareRecordError)
            case growthRecordsLoaded([CareRecord])
        }

        case binding(BindingAction<State>)
        case task
        case growthChartButtonTapped
        case _internal(InternalAction)
        case path(StackAction<Path.State, Path.Action>)
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

            case let ._internal(.recordsLoaded(records)):
                state.records = records
                return .none

            case ._internal(.recordsLoadFailed):
                state.records = []
                return .none

            case let ._internal(.growthRecordsLoaded(records)):
                state.growthRecords = records.filter { $0.event.category == .growth }
                return .none

            case .growthChartButtonTapped:
                state.path.append(.growthChart(GrowthChartFeature.State(records: state.growthRecords, baby: state.baby)))
                return .none

            case .path:
                return .none

            case .binding:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }

    private func loadGrowthRecords(for state: State) -> Effect<Action> {
        let babyID = state.baby.id
        let start = state.baby.birthDate
        let calendar = Calendar.current
        guard let end = calendar.date(byAdding: .day, value: 1, to: Date()) else { return .none }

        return .run { [careRecordClient] send in
            do throws(CareRecordError) {
                let records = try await careRecordClient.loadRecords(babyID, start ..< end)
                await send(._internal(.growthRecordsLoaded(records)))
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
                await send(._internal(.recordsLoaded(records)))
            } catch {
                await send(._internal(.recordsLoadFailed(error)))
            }
        }
    }
}

extension CareEvent.Category {
    static let statisticFilterCases: [CareEvent.Category] = [.feeding, .potty, .sleep, .bath, .snack]
}

public extension StatisticFeature {
    enum Mode: String, CaseIterable, Hashable, Sendable {
        case daily = "일"
        case weekly = "주"

        public var stepDays: Int {
            switch self {
            case .daily: 1
            case .weekly: 7
            }
        }
    }
}

extension StatisticFeature {
    @Reducer
    public enum Path {
        case growthChart(GrowthChartFeature)
        case snackDetail(SnackDetailFeature)
        case bathDetail(BathDetailFeature)
        case pottyDetail(PottyDetailFeature)
    }
}

extension StatisticFeature.Path.State: Equatable {}
