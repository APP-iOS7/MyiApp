import ComposableArchitecture
import DesignSystem
import Domain
import Foundation

@Reducer
public struct FoodDetailFeature {
    public struct FeedingTrend: Identifiable, Equatable {
        public let type: FeedingType
        public let entries: [TrendBarChart.Entry]
        public var id: FeedingType { type }
    }

    public enum FeedingType: String, CaseIterable, Hashable, Sendable {
        case formula = "분유"
        case babyFood = "이유식"
        case pumpedMilk = "유축수유"
        case breastfeeding = "모유수유"

        public var unit: String { self == .breastfeeding ? "분" : "ml" }

        public func amount(in records: [CareRecord]) -> Int {
            records.reduce(0) { total, record in
                switch self {
                case .formula:
                    if case let .formula(ml) = record.event { return total + ml }
                case .babyFood:
                    if case let .babyFood(ml) = record.event { return total + ml }
                case .pumpedMilk:
                    if case let .pumpedMilk(ml) = record.event { return total + ml }
                case .breastfeeding:
                    if case let .breastfeeding(left, right) = record.event { return total + left + right }
                }
                return total
            }
        }
    }

    @ObservableState
    public struct State: Equatable {
        public var baby: Baby
        public var records: [CareRecord]
        public var selectedDate: Date
        public var mode: DetailMode

        public init(
            baby: Baby,
            records: [CareRecord] = [],
            selectedDate: Date = Date(),
            mode: DetailMode = .daily
        ) {
            self.baby = baby
            self.records = records
            self.selectedDate = selectedDate
            self.mode = mode
        }

        var currentRange: Range<Date> { mode.currentRange(of: selectedDate) }
        var previousRange: Range<Date> { mode.previousRange(of: selectedDate) }

        var feedingCount: Int { records.filtered(in: currentRange).count(of: .feeding) }
        var previousFeedingCount: Int { records.filtered(in: previousRange).count(of: .feeding) }
        var totalMl: Int { records.filtered(in: currentRange).totalMl }
        var previousTotalMl: Int { records.filtered(in: previousRange).totalMl }
        var breastfeedingMinutes: Int { records.filtered(in: currentRange).totalBreastfeedingMinutes }
        var previousBreastfeedingMinutes: Int { records.filtered(in: previousRange).totalBreastfeedingMinutes }

        var feedingTrends: [FeedingTrend] {
            FeedingType.allCases.map { type in
                let entries = mode.trailingPeriodStarts(from: selectedDate, count: 7).map { start in
                    let range = mode.currentRange(of: start)
                    let value = type.amount(in: records.filtered(in: range))
                    return TrendBarChart.Entry(
                        id: start,
                        label: mode.axisLabel(for: start),
                        value: Double(value)
                    )
                }
                return FeedingTrend(type: type, entries: entries)
            }
        }

        var comparisonMessage: String {
            if feedingCount == previousFeedingCount {
                return "\(mode.previousLabel)와 수유 횟수가 동일합니다."
            }
            let direction = feedingCount > previousFeedingCount ? "증가" : "감소"
            return "\(mode.previousLabel)보다 수유 횟수가 \(direction)하였습니다."
        }
    }

    public enum Action: BindableAction {
        public enum ViewAction {
            case task
        }

        public enum InternalAction {
            case recordsLoaded([CareRecord])
            case recordsLoadFailed(CareRecordError)
        }

        case view(ViewAction)
        case _internal(InternalAction)

        case binding(BindingAction<State>)
    }

    @Dependency(\.careRecordClient) var careRecordClient

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .view(.task):
                return loadRecords(for: state)

            case .binding(\.mode), .binding(\.selectedDate):
                return loadRecords(for: state)

            case let ._internal(.recordsLoaded(records)):
                state.records = records
                return .none

            case ._internal(.recordsLoadFailed):
                state.records = []
                return .none

            case .binding:
                return .none
            }
        }
    }

    private func loadRecords(for state: State) -> Effect<Action> {
        let babyID = state.baby.id
        let starts = state.mode.trailingPeriodStarts(from: state.selectedDate, count: 7)
        guard let earliest = starts.first else { return .none }

        let latestEnd = state.mode.currentRange(of: state.selectedDate).upperBound

        return .run { [careRecordClient] send in
            do throws(CareRecordError) {
                let records = try await careRecordClient.loadRecords(babyID, earliest ..< latestEnd)
                await send(._internal(.recordsLoaded(records)))
            } catch {
                await send(._internal(.recordsLoadFailed(error)))
            }
        }
    }
}
