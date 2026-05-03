import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct SnackDetailFeature {
    @ObservableState
    public struct State: Equatable {
        public var baby: Baby
        public var records: [CareRecord]
        public var selectedDate: Date
        public var mode: StatisticFeature.Mode

        public init(
            baby: Baby,
            records: [CareRecord] = [],
            selectedDate: Date = Date(),
            mode: StatisticFeature.Mode = .daily
        ) {
            self.baby = baby
            self.records = records
            self.selectedDate = selectedDate
            self.mode = mode
        }

        var previousDate: Date {
            Calendar.current.date(byAdding: .day, value: -mode.stepDays, to: selectedDate) ?? selectedDate
        }

        var count: Int { records.filtered(on: selectedDate).count(of: .snack) }
        var previousCount: Int { records.filtered(on: previousDate).count(of: .snack) }
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
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: state.selectedDate)
        guard let start = calendar.date(byAdding: .day, value: -state.mode.stepDays, to: dayStart),
              let end = calendar.date(byAdding: .day, value: 1, to: dayStart)
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
