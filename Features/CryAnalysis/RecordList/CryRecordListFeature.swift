import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct CryRecordListFeature {
    @ObservableState
    public struct State: Equatable {
        public var baby: Baby
        public var records: [CryAnalysisRecord] = []

        public init(baby: Baby) {
            self.baby = baby
        }
    }

    public enum Action {
        public enum ViewAction {
            case task
            case deleteTapped(UUID)
        }

        public enum InternalAction {
            case recordsLoaded([CryAnalysisRecord])
            case recordsLoadFailed(CryRecordError)
            case deleteSucceeded(UUID)
        }

        case view(ViewAction)
        case _internal(InternalAction)
    }

    @Dependency(\.cryRecordClient) var cryRecordClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.task):
                return loadRecords(for: state)

            case let .view(.deleteTapped(recordID)):
                let babyID = state.baby.id
                return .run { [cryRecordClient] send in
                    do throws(CryRecordError) {
                        try await cryRecordClient.deleteRecord(babyID, recordID)
                        await send(._internal(.deleteSucceeded(recordID)))
                    } catch {
                        // 삭제 실패는 조용히 무시 (UI 알림은 후속에서)
                    }
                }

            case let ._internal(.recordsLoaded(records)):
                state.records = records.sorted { $0.createdAt > $1.createdAt }
                return .none

            case ._internal(.recordsLoadFailed):
                state.records = []
                return .none

            case let ._internal(.deleteSucceeded(recordID)):
                state.records.removeAll { $0.id == recordID }
                return .none
            }
        }
    }

    private func loadRecords(for state: State) -> Effect<Action> {
        let babyID = state.baby.id
        let start = state.baby.birthDate
        let calendar = Calendar.current
        guard let end = calendar.date(byAdding: .day, value: 1, to: Date()) else { return .none }

        return .run { [cryRecordClient] send in
            do throws(CryRecordError) {
                let records = try await cryRecordClient.loadRecords(babyID, start ..< end)
                await send(._internal(.recordsLoaded(records)))
            } catch {
                await send(._internal(.recordsLoadFailed(error)))
            }
        }
    }
}
