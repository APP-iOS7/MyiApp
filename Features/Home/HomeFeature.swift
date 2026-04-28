import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct HomeFeature {
    @ObservableState
    public struct State: Equatable {
        public var baby: Baby
        public var selectedDate: Date
        public var records: [CareRecord]

        public init(
            baby: Baby,
            selectedDate: Date = Date(),
            records: [CareRecord] = []
        ) {
            self.baby = baby
            self.selectedDate = selectedDate
            self.records = records
        }

        var filteredRecords: [CareRecord] {
            let cal = Calendar.current
            return records
                .filter { cal.isDate($0.createdAt, inSameDayAs: selectedDate) }
                .sorted { $0.createdAt < $1.createdAt }
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
            case .task, .binding(\.selectedDate):
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
        let start = cal.startOfDay(for: state.selectedDate)
        guard let end = cal.date(byAdding: .day, value: 1, to: start) else { return .none }

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
