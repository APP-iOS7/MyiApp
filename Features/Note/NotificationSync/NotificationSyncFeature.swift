import ComposableArchitecture
import Domain
import Foundation
import Shared

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
        public enum ViewAction {
            case task
            case babyChanged(UUID?)
        }

        public enum InternalAction {
            case notesReceived([Note])
        }

        case view(ViewAction)
        case _internal(InternalAction)
    }

    private enum CancelID { case stream }

    @Dependency(\.noteClient) var noteClient
    @Dependency(\.localNotificationClient) var localNotificationClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.task):
                guard let babyID = state.babyID else {
                    AppLogger.info("babyID nil — listener stop")
                    return .cancel(id: CancelID.stream)
                }
                AppLogger.info("listener start for baby=\(babyID)")
                return .run { [noteClient] send in
                    for await notes in noteClient.streamFutureScheduleNotes(babyID) {
                        await send(._internal(.notesReceived(notes)))
                    }
                }
                .cancellable(id: CancelID.stream, cancelInFlight: true)

            case let .view(.babyChanged(newID)):
                let previousIDs = state.scheduledIDs
                AppLogger.info("baby changed: \(state.babyID?.uuidString ?? "nil") → \(newID?.uuidString ?? "nil"), cancel \(previousIDs.count) prior")
                state.scheduledIDs = []
                state.babyID = newID
                return .merge(
                    .run { [localNotificationClient] _ in
                        for id in previousIDs {
                            await localNotificationClient.cancel(id)
                        }
                    },
                    .send(.view(.task))
                )

            case let ._internal(.notesReceived(notes)):
                let now = Date()
                let target = notes.filter { note in
                    guard let reminder = note.reminder else { return false }
                    return reminder.scheduledAt > now
                }
                let targetIDs = Set(target.map(\.id))
                let added = targetIDs.subtracting(state.scheduledIDs)
                let removed = state.scheduledIDs.subtracting(targetIDs)
                AppLogger.info("notes=\(notes.count) target=\(target.count) added=\(added.count) removed=\(removed.count)")
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
                            AppLogger.debug("scheduled \(note.id) at \(reminder.scheduledAt)")
                        } catch {
                            AppLogger.error("schedule failed: \(error) for \(note.id)")
                        }
                    }
                    for id in removed {
                        await localNotificationClient.cancel(id)
                        AppLogger.debug("cancelled \(id)")
                    }
                }
            }
        }
    }
}
