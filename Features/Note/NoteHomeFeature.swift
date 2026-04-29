import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct NoteHomeFeature {
    @ObservableState
    public struct State: Equatable {
        public var baby: Baby
        public var month: Date
        public var selected: Date
        public var notes: [Note]
        public var sheet: Sheet?

        public init(
            baby: Baby,
            month: Date = Date(),
            selected: Date = Date(),
            notes: [Note] = [],
            sheet: Sheet? = nil
        ) {
            self.baby = baby
            self.month = month
            self.selected = selected
            self.notes = notes
            self.sheet = sheet
        }
    }

    public enum Sheet: Equatable, Identifiable {
        case diary(Date)
        case schedule(Date)

        public var id: String {
            switch self {
            case let .diary(date): "diary-\(date.timeIntervalSince1970)"
            case let .schedule(date): "schedule-\(date.timeIntervalSince1970)"
            }
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case task
        case diaryButtonTapped
        case scheduleButtonTapped
        case noteSaved(Note)
        case _internal(Internal)

        public enum Internal {
            case reload
            case notesLoaded([Note])
        }
    }

    @Dependency(\.noteClient) var noteClient

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .task:
                return loadEffect(state: state)

            case .binding(\.month):
                return loadEffect(state: state)

            case .binding:
                return .none

            case .diaryButtonTapped:
                state.sheet = .diary(state.selected)
                return .none

            case .scheduleButtonTapped:
                state.sheet = .schedule(state.selected)
                return .none

            case let .noteSaved(note):
                state.sheet = nil
                return .run { [noteClient, babyID = state.baby.id] send in
                    try? await noteClient.addNote(babyID, note)
                    await send(._internal(.reload))
                }

            case ._internal(.reload):
                return loadEffect(state: state)

            case let ._internal(.notesLoaded(notes)):
                state.notes = notes
                return .none
            }
        }
    }

    private func loadEffect(state: State) -> Effect<Action> {
        guard let interval = Calendar.current.dateInterval(of: .month, for: state.month) else { return .none }

        return .run { [noteClient, babyID = state.baby.id] send in
            if let notes = try? await noteClient.loadNotes(babyID, interval.start ..< interval.end) {
                await send(._internal(.notesLoaded(notes)))
            }
        }
    }
}
