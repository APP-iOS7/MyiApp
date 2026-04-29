import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct ScheduleEditorFeature {
    @ObservableState
    public struct State: Equatable {
        public var title: String
        public var description: String
        public var date: Date
        public var reminderMode: ReminderMode

        public init(
            date: Date = Date(),
            title: String = "",
            description: String = "",
            reminderMode: ReminderMode = .none
        ) {
            self.date = date
            self.title = title
            self.description = description
            self.reminderMode = reminderMode
        }

        public var canSave: Bool { !title.isEmpty }

        public var isCustomReminder: Bool {
            if case .custom = reminderMode { return true }
            return false
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case reminderPresetSelected(ReminderMode)
        case customReminderSelected
        case customReminderChanged(Date)
        case cancelButtonTapped
        case saveButtonTapped
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case saved(Note)
            case cancelled
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .reminderPresetSelected(mode):
                state.reminderMode = mode
                return .none

            case .customReminderSelected:
                state.reminderMode = .custom(defaultCustomReminder(for: state.date))
                return .none

            case let .customReminderChanged(date):
                state.reminderMode = .custom(date)
                return .none

            case .cancelButtonTapped:
                return .send(.delegate(.cancelled))

            case .saveButtonTapped:
                let reminder: Reminder? = switch state.reminderMode {
                case .none:
                    nil
                case let .minutesBefore(minutes):
                    Reminder(scheduledAt: state.date.addingTimeInterval(-Double(minutes) * 60))
                case let .custom(alertDate):
                    Reminder(scheduledAt: alertDate)
                }
                let note = Note(
                    kind: .schedule,
                    title: state.title,
                    description: state.description,
                    date: state.date,
                    reminder: reminder
                )
                return .send(.delegate(.saved(note)))

            case .binding, .delegate:
                return .none
            }
        }
    }

    private func defaultCustomReminder(for scheduledAt: Date) -> Date {
        Calendar.current.date(byAdding: .hour, value: -1, to: scheduledAt) ?? scheduledAt
    }
}
