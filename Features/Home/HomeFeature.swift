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
        @Presents public var editRecord: EditRecordFeature.State?

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
        case timelineRowTapped(CareRecord)
        case editRecord(PresentationAction<EditRecordFeature.Action>)
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
                let now = Date()
                let cal = Calendar.current
                let createdAt = cal.date(
                    bySettingHour: cal.component(.hour, from: now),
                    minute: cal.component(.minute, from: now),
                    second: cal.component(.second, from: now),
                    of: state.selectedDate
                ) ?? now
                return .run { [careRecordClient] send in
                    do throws(CareRecordError) {
                        let event: CareEvent?
                        switch entry {
                        case .feeding:
                            event = try await careRecordClient.lastEvent(babyID, .feeding) ?? .formula(ml: 100)
                        case .potty:
                            event = .pee
                        case .sleep:
                            event = .sleep(start: createdAt, end: nil)
                        case .heightWeight:
                            event = try await careRecordClient.lastEvent(babyID, .growth)
                                ?? .heightWeight(heightCm: nil, weightKg: nil)
                        case .bath:
                            event = .bath
                        case .snack:
                            event = .snack
                        case .health:
                            event = try await careRecordClient.lastEvent(babyID, .vital) ?? .temperature(celsius: 36.5)
                        case .memo:
                            event = .clinic
                        }
                        guard let event else { return }
                        try await careRecordClient.addRecord(babyID, CareRecord(createdAt: createdAt, event: event))
                        await send(.recordAdded)
                    } catch {
                        await send(.recordAddFailed(error))
                    }
                }

            case .recordAdded:
                return loadRecords(for: state)

            case .recordAddFailed:
                return .none

            case let .timelineRowTapped(record):
                state.editRecord = EditRecordFeature.State(record: record, babyID: state.baby.id)
                return .none

            case .editRecord(.presented(.delegate(.saved))),
                 .editRecord(.presented(.delegate(.deleted))):
                return loadRecords(for: state)

            case .editRecord, .binding:
                return .none
            }
        }
        .ifLet(\.$editRecord, action: \.editRecord) {
            EditRecordFeature()
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
