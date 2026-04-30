import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct ScheduleEditorFeature {
    @ObservableState
    public struct State: Equatable {
        public var babyID: UUID
        public var title: String
        public var description: String
        public var date: Date
        public var reminderMode: ReminderMode
        public var isSaving: Bool
        @Presents public var alert: AlertState<Action.Alert>?

        public init(
            babyID: UUID,
            date: Date = Date(),
            title: String = "",
            description: String = "",
            reminderMode: ReminderMode = .none,
            isSaving: Bool = false,
            alert: AlertState<Action.Alert>? = nil
        ) {
            self.babyID = babyID
            self.date = date
            self.title = title
            self.description = description
            self.reminderMode = reminderMode
            self.isSaving = isSaving
            self.alert = alert
        }

        public var canSave: Bool { !title.isEmpty && !isSaving }

        public var isCustomReminder: Bool {
            if case .custom = reminderMode { return true }
            return false
        }
    }

    public enum Action: BindableAction {
        public enum ViewAction {
            case reminderPresetSelected(ReminderMode)
            case customReminderSelected
            case customReminderChanged(Date)
            case cancelButtonTapped
            case saveButtonTapped
        }

        public enum Internal {
            case reminderAuthorizationResolved(LocalNotificationAuthorization, pendingMode: ReminderMode)
            case saveCompleted
            case saveFailed(NoteError)
        }

        public enum Delegate: Equatable {
            case saved
            case cancelled
        }

        public enum Alert: Equatable {
            case openSettings
        }

        case binding(BindingAction<State>)
        case view(ViewAction)
        case _internal(Internal)
        case delegate(Delegate)
        case alert(PresentationAction<Alert>)
    }

    @Dependency(\.noteClient) var noteClient
    @Dependency(\.localNotificationClient) var localNotificationClient
    @Dependency(\.openURL) var openURL
    @Dependency(\.authClient) var authClient

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .view(.reminderPresetSelected(mode)):
                if case .none = mode {
                    state.reminderMode = .none
                    return .none
                }
                return checkReminderAuthorization(pendingMode: mode)

            case .view(.customReminderSelected):
                let customDate = Calendar.current.date(byAdding: .hour, value: -1, to: state.date) ?? state.date
                return checkReminderAuthorization(pendingMode: .custom(customDate))

            case let .view(.customReminderChanged(date)):
                state.reminderMode = .custom(date)
                return .none

            case let ._internal(.reminderAuthorizationResolved(authorization, mode)):
                AppLogger.info("reminder authorization resolved: \(authorization)")
                switch authorization {
                case .authorized:
                    state.reminderMode = mode
                    return .none
                case .notDetermined:
                    return checkReminderAuthorization(pendingMode: mode)
                case .denied:
                    state.alert = AlertState {
                        TextState("알림이 꺼져있어요")
                    } actions: {
                        ButtonState(action: .openSettings) {
                            TextState("설정 열기")
                        }
                        ButtonState(role: .cancel) {
                            TextState("취소")
                        }
                    } message: {
                        TextState("일정 알림을 받으려면 설정에서 알림을 허용해주세요.")
                    }
                    return .none
                }

            case .view(.cancelButtonTapped):
                return .send(.delegate(.cancelled))

            case .view(.saveButtonTapped):
                guard !state.isSaving else { return .none }
                guard let session = authClient.current() else {
                    AppLogger.error("save aborted: not authenticated")
                    state.isSaving = false
                    return .send(._internal(.saveFailed(.unauthorized)))
                }
                state.isSaving = true
                let reminder: Reminder? = switch state.reminderMode {
                case .none:
                    nil
                case let .minutesBefore(minutes):
                    Reminder(scheduledAt: state.date.addingTimeInterval(-Double(minutes) * 60))
                case let .custom(alertDate):
                    Reminder(scheduledAt: alertDate)
                }
                let note = Note(
                    creatorID: session.uid,
                    kind: .schedule,
                    title: state.title,
                    description: state.description,
                    date: state.date,
                    reminder: reminder
                )
                return .run { [noteClient, babyID = state.babyID] send in
                    do throws(NoteError) {
                        try await noteClient.addNote(babyID, note)
                    } catch {
                        await send(._internal(.saveFailed(error)))
                        return
                    }
                    await send(._internal(.saveCompleted))
                }

            case ._internal(.saveCompleted):
                state.isSaving = false
                return .send(.delegate(.saved))

            case ._internal(.saveFailed):
                state.isSaving = false
                state.alert = AlertState {
                    TextState("저장 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState("일정 저장 중 문제가 발생했습니다. 잠시 후 다시 시도해주세요.")
                }
                return .none

            case .alert(.presented(.openSettings)):
                return .run { [openURL] _ in
                    guard let url = URL(string: "app-settings:") else { return }
                    await openURL(url)
                }

            case .alert:
                return .none

            case .binding, .delegate:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }

    private func checkReminderAuthorization(pendingMode: ReminderMode) -> Effect<Action> {
        .run { [localNotificationClient] send in
            let status = await localNotificationClient.authorizationStatus()
            AppLogger.debug("authorization status checked: \(status)")
            let resolved: LocalNotificationAuthorization
            switch status {
            case .notDetermined:
                let granted = await localNotificationClient.requestPermission()
                AppLogger.info("permission requested, granted=\(granted)")
                resolved = granted ? .authorized : .denied
            case .authorized, .denied:
                resolved = status
            }
            await send(._internal(.reminderAuthorizationResolved(resolved, pendingMode: pendingMode)))
        }
    }
}
