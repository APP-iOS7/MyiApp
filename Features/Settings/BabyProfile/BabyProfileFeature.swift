import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct BabyProfileFeature {
    @ObservableState
    public struct State: Equatable {
        public var baby: Baby

        public init(baby: Baby) {
            self.baby = baby
        }
    }

    public enum Action: BindableAction {
        public enum InternalAction {
            case babyUpdated(Baby)
        }
        public enum DelegateAction: Equatable {
            case editNameTapped(Baby)
            case editBirthDateTapped(Baby)
        }

        case binding(BindingAction<State>)
        case task
        case nameRowTapped
        case birthDateRowTapped
        case _internal(InternalAction)
        case delegate(DelegateAction)
    }

    @Dependency(\.babyClient) var babyClient

    private enum CancelID { case babyStream }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .task:
                return .run { [babyClient, id = state.baby.id] send in
                    for await baby in babyClient.streamBaby(id) {
                        await send(._internal(.babyUpdated(baby)))
                    }
                }
                .cancellable(id: CancelID.babyStream, cancelInFlight: true)

            case .nameRowTapped:
                return .send(.delegate(.editNameTapped(state.baby)))

            case .birthDateRowTapped:
                return .send(.delegate(.editBirthDateTapped(state.baby)))

            case let ._internal(.babyUpdated(baby)):
                state.baby = baby
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
