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
                .sorted { $0.createdAt > $1.createdAt }
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case task
        case recordsLoaded([CareRecord])
        case recordsLoadFailed(CareRecordError)
        case careEntryTapped(HomeCareEntry)
        case recordAdded
        case recordAddFailed(CareRecordError)
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

            case let .careEntryTapped(entry):
                let babyID = state.baby.id
                return .run { [careRecordClient] send in
                    do throws(CareRecordError) {
                        guard let event = try await defaultEvent(for: entry, babyID: babyID, client: careRecordClient) else {
                            return
                        }
                        let record = CareRecord(event: event)
                        try await careRecordClient.addRecord(babyID, record)
                        await send(.recordAdded)
                    } catch {
                        await send(.recordAddFailed(error))
                    }
                }

            case .recordAdded:
                return loadRecords(for: state)

            case .recordAddFailed:
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

/// 카테고리별 quick-add 기본값.
/// 직전 값을 재사용해야 하면 client.lastEvent를 통해 조회.
private func defaultEvent(
    for entry: HomeCareEntry,
    babyID: UUID,
    client: CareRecordClient
) async throws(CareRecordError) -> CareEvent? {
    let now = Date()
    switch entry {
    case .feeding:
        return try await client.lastEvent(babyID, .feeding) ?? .formula(ml: 100)
    case .potty:
        return .pee
    case .sleep:
        return .sleep(start: now, end: nil)
    case .heightWeight:
        return try await client.lastEvent(babyID, .growth) ?? .heightWeight(heightCm: nil, weightKg: nil)
    case .bath:
        return .bath
    case .snack:
        return .snack
    case .health:
        return .temperature(celsius: 36.5)
    case .memo:
        return .clinic
    }
}
