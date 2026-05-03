import ComposableArchitecture
import DesignSystem
import Domain
import Foundation

@Reducer
public struct PottyDetailFeature {
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

        var current: (pee: Int, poop: Int) { records.filtered(in: currentRange).pottyCount }
        var previous: (pee: Int, poop: Int) { records.filtered(in: previousRange).pottyCount }

        var peeTrend: [TrendBarChart.Entry] { trend(\.pee) }
        var poopTrend: [TrendBarChart.Entry] { trend(\.poop) }

        private func trend(_ keyPath: KeyPath<(pee: Int, poop: Int), Int>) -> [TrendBarChart.Entry] {
            mode.trailingPeriodStarts(from: selectedDate, count: 7).map { start in
                let range = mode.currentRange(of: start)
                let value = records.filtered(in: range).pottyCount[keyPath: keyPath]
                return TrendBarChart.Entry(
                    id: start,
                    label: mode.axisLabel(for: start),
                    value: Double(value)
                )
            }
        }

        var comparisonMessage: String {
            let peeDirection = comparisonText(current: current.pee, previous: previous.pee, label: "소변")
            let poopDirection = comparisonText(current: current.poop, previous: previous.poop, label: "대변")
            return "\(mode.previousLabel)보다 \(peeDirection), \(poopDirection)."
        }

        private func comparisonText(current: Int, previous: Int, label: String) -> String {
            if current == previous { return "\(label) 횟수 동일" }
            return "\(label) 횟수 \(current > previous ? "증가" : "감소")"
        }
    }

    public enum Action: BindableAction {
        public enum InternalAction {
            case recordsLoaded([CareRecord])
            case recordsLoadFailed(CareRecordError)
        }

        case binding(BindingAction<State>)
        case task
        case _internal(InternalAction)
    }

    @Dependency(\.careRecordClient) var careRecordClient

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .task:
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
