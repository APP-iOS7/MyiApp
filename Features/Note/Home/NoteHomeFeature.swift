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
        @Presents public var destination: Destination.State?

        public init(
            baby: Baby,
            month: Date = Date(),
            selected: Date = Date(),
            notes: [Note] = [],
            destination: Destination.State? = nil
        ) {
            self.baby = baby
            self.month = month
            self.selected = selected
            self.notes = notes
            self.destination = destination
        }

        public var isPastDay: Bool {
            Calendar.current.startOfDay(for: selected) < Calendar.current.startOfDay(for: Date())
        }

        public var isFutureDay: Bool {
            Calendar.current.startOfDay(for: selected) > Calendar.current.startOfDay(for: Date())
        }

        public var notesOfDay: [Note] {
            notes.filter { Calendar.current.isDate($0.date, inSameDayAs: selected) }
        }

        public var datesWithIndicator: Set<Date> {
            Set(notes.map { Calendar.current.startOfDay(for: $0.date) })
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case task
        case diaryButtonTapped
        case scheduleButtonTapped
        case destination(PresentationAction<Destination.Action>)
        case _internal(Internal)

        public enum Internal {
            case notesLoaded([Note])
        }
    }

    private enum CancelID { case notesStream }

    @Dependency(\.noteClient) var noteClient

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .task:
                return streamEffect(state: state)

            case .binding(\.month):
                return streamEffect(state: state)

            case .binding:
                return .none

            case .diaryButtonTapped:
                state.destination = .diary(DiaryEditorFeature.State(
                    babyID: state.baby.id,
                    date: state.selected
                ))
                return .none

            case .scheduleButtonTapped:
                let defaultTime = Calendar.current.date(
                    bySettingHour: 12,
                    minute: 0,
                    second: 0,
                    of: state.selected
                ) ?? state.selected
                state.destination = .schedule(ScheduleEditorFeature.State(
                    babyID: state.baby.id,
                    date: defaultTime
                ))
                return .none

            case .destination(.presented(.diary(.delegate(.saved)))),
                 .destination(.presented(.schedule(.delegate(.saved)))),
                 .destination(.presented(.diary(.delegate(.cancelled)))),
                 .destination(.presented(.schedule(.delegate(.cancelled)))):
                state.destination = nil
                return .none

            case .destination:
                return .none

            case let ._internal(.notesLoaded(notes)):
                state.notes = notes
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }

    private func streamEffect(state: State) -> Effect<Action> {
        guard let interval = Calendar.current.dateInterval(of: .month, for: state.month) else { return .none }

        return .run { [noteClient, babyID = state.baby.id] send in
            for await notes in noteClient.streamNotes(babyID, interval.start ..< interval.end) {
                await send(._internal(.notesLoaded(notes)))
            }
        }
        .cancellable(id: CancelID.notesStream, cancelInFlight: true)
    }
}

extension NoteHomeFeature {
    @Reducer
    public enum Destination {
        case diary(DiaryEditorFeature)
        case schedule(ScheduleEditorFeature)
    }
}

extension NoteHomeFeature.Destination.State: Equatable {}
