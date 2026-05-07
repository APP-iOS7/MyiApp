import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct HomeFeature {
    @ObservableState
    public struct State: Equatable {
        public var baby: Baby
        public var babies: IdentifiedArrayOf<Baby> = []
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
            let calendar = Calendar.current
            return records
                .filter { calendar.isDate($0.createdAt, inSameDayAs: selectedDate) }
                .sorted { $0.createdAt > $1.createdAt }
        }
    }

    public enum Action: BindableAction {
        public enum ViewAction {
            case task
            case careEntryTapped(HomeCareEntry)
            case timelineRowTapped(CareRecord)
            case timelineRowDeleted(UUID)
            case babySelected(Baby.ID)
        }

        public enum InternalAction {
            case recordsLoaded([CareRecord])
            case recordsLoadFailed(CareRecordError)
            case recordAdded
            case recordAddFailed(CareRecordError)
            case recordDeleted
            case recordDeleteFailed(CareRecordError)
        }

        public enum Delegate: Equatable {
            case babyChangeRequested(Baby.ID)
        }

        case view(ViewAction)
        case _internal(InternalAction)
        case delegate(Delegate)

        case binding(BindingAction<State>)
        case editRecord(PresentationAction<EditRecordFeature.Action>)
    }

    @Dependency(\.analytics) var analytics
    @Dependency(\.careRecordClient) var careRecordClient

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .view(.task):
                return .merge(
                    loadRecords(for: state),
                    .run { [analytics] _ in analytics.trackScreen(.home) }
                )

            case .binding(\.selectedDate):
                return loadRecords(for: state)

            case let .view(.careEntryTapped(entry)):
                return addEntry(entry, state: state)

            case let .view(.timelineRowTapped(record)):
                state.editRecord = EditRecordFeature.State(record: record, babyID: state.baby.id)
                return .none

            case let .view(.timelineRowDeleted(recordID)):
                return deleteRecord(recordID, babyID: state.baby.id)

            case let .view(.babySelected(id)):
                guard id != state.baby.id else { return .none }

                return .send(.delegate(.babyChangeRequested(id)))

            case let ._internal(.recordsLoaded(records)):
                state.records = records
                return .none

            case ._internal(.recordsLoadFailed):
                state.records = []
                return .none

            case ._internal(.recordAdded), ._internal(.recordDeleted):
                return loadRecords(for: state)

            case ._internal(.recordAddFailed), ._internal(.recordDeleteFailed):
                return .none

            case .editRecord(.presented(.delegate(.saved))),
                 .editRecord(.presented(.delegate(.deleted))):
                return loadRecords(for: state)

            case .delegate, .editRecord, .binding:
                return .none
            }
        }
        .ifLet(\.$editRecord, action: \.editRecord) {
            EditRecordFeature()
        }
    }

    private func loadRecords(for state: State) -> Effect<Action> {
        let babyID = state.baby.id
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: state.selectedDate)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return .none }

        return .run { [careRecordClient] send in
            do throws(CareRecordError) {
                let records = try await careRecordClient.loadRecords(babyID, start ..< end)
                await send(._internal(.recordsLoaded(records)))
            } catch {
                await send(._internal(.recordsLoadFailed(error)))
            }
        }
    }

    private func addEntry(_ entry: HomeCareEntry, state: State) -> Effect<Action> {
        let babyID = state.baby.id
        let now = Date()
        let calendar = Calendar.current
        let createdAt = calendar.date(
            bySettingHour: calendar.component(.hour, from: now),
            minute: calendar.component(.minute, from: now),
            second: calendar.component(.second, from: now),
            of: state.selectedDate
        ) ?? now

        return .run { [analytics, careRecordClient] send in
            do throws(CareRecordError) {
                let event: CareEvent? = switch entry {
                case .feeding:
                    try await careRecordClient.lastEvent(babyID, .feeding) ?? .formula(ml: 100)

                case .potty:
                    .pee

                case .sleep:
                    .sleep(start: createdAt, end: nil)

                case .heightWeight:
                    try await careRecordClient.lastEvent(babyID, .growth)
                        ?? .heightWeight(heightCm: nil, weightKg: nil)

                case .bath:
                    .bath

                case .snack:
                    .snack

                case .health:
                    try await careRecordClient.lastEvent(babyID, .vital) ?? .temperature(celsius: 36.5)

                case .memo:
                    .clinic
                }
                guard let event else { return }

                try await careRecordClient.addRecord(babyID, CareRecord(createdAt: createdAt, event: event))
                analytics.track(.careRecordSaved(category: event.category))
                await send(._internal(.recordAdded))
            } catch {
                await send(._internal(.recordAddFailed(error)))
            }
        }
    }

    private func deleteRecord(_ recordID: UUID, babyID: UUID) -> Effect<Action> {
        .run { [careRecordClient] send in
            do throws(CareRecordError) {
                try await careRecordClient.deleteRecord(babyID, recordID)
                await send(._internal(.recordDeleted))
            } catch {
                await send(._internal(.recordDeleteFailed(error)))
            }
        }
    }
}
