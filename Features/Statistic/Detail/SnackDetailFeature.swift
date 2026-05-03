import ComposableArchitecture
import DesignSystem
import Domain
import Foundation

@Reducer
public struct SnackDetailFeature {
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

        var count: Int { records.filtered(in: currentRange).count(of: .snack) }
        var previousCount: Int { records.filtered(in: previousRange).count(of: .snack) }

        var trendEntries: [TrendBarChart.Entry] {
            mode.trailingPeriodStarts(from: selectedDate, count: 7).map { start in
                let range = mode.currentRange(of: start)
                let count = records.filtered(in: range).count(of: .snack)
                return TrendBarChart.Entry(
                    id: start,
                    label: mode.axisLabel(for: start),
                    value: Double(count)
                )
            }
        }

        var comparisonMessage: String {
            if count == previousCount {
                return "\(mode.previousLabel)와 동일합니다."
            }
            let direction = count > previousCount ? "증가" : "감소"
            return "\(mode.previousLabel)보다 간식 횟수가 \(direction)하였습니다."
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
