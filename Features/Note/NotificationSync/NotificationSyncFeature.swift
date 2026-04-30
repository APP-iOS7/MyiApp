import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct NotificationSyncFeature {
    @ObservableState
    public struct State: Equatable {
        public var babyID: UUID?
        public var scheduledIDs: Set<UUID>

        public init(babyID: UUID? = nil, scheduledIDs: Set<UUID> = []) {
            self.babyID = babyID
            self.scheduledIDs = scheduledIDs
        }
    }

    public enum Action {
        case task
        case babyChanged(UUID?)
        case _internal(Internal)

        public enum Internal {
            case notesReceived([Note])
        }
    }

    private enum CancelID { case stream }

    @Dependency(\.noteClient) var noteClient
    @Dependency(\.localNotificationClient) var localNotificationClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                guard let babyID = state.babyID else {
                    return .cancel(id: CancelID.stream)
                }
                return .run { [noteClient] send in
                    for await notes in noteClient.streamFutureScheduleNotes(babyID) {
                        await send(._internal(.notesReceived(notes)))
                    }
                }
                .cancellable(id: CancelID.stream, cancelInFlight: true)

            case let .babyChanged(newID):
                let previousIDs = state.scheduledIDs
                state.scheduledIDs = []
                state.babyID = newID
                return .merge(
                    .run { [localNotificationClient] _ in
                        for id in previousIDs {
                            await localNotificationClient.cancel(id)
                        }
                    },
                    .send(.task)
                )

            case let ._internal(.notesReceived(notes)):
                let now = Date()
                let target = notes.filter { note in
                    guard let reminder = note.reminder else { return false }
                    return reminder.scheduledAt > now
                }
                let targetIDs = Set(target.map(\.id))
                let removed = state.scheduledIDs.subtracting(targetIDs)
                state.scheduledIDs = targetIDs
                return .run { [localNotificationClient] _ in
                    for note in target {
                        guard let reminder = note.reminder else { continue }
                        do throws(LocalNotificationError) {
                            try await localNotificationClient.schedule(
                                LocalNotificationRequest(
                                    id: note.id,
                                    title: note.title,
                                    body: note.description.isEmpty ? nil : note.description,
                                    scheduledAt: reminder.scheduledAt
                                )
                            )
                        } catch {
                            print("[NotificationSync] schedule failed: \(error) for \(note.id)")
                        }
                    }
                    for id in removed {
                        await localNotificationClient.cancel(id)
                    }
                }
            }
        }
    }
}
