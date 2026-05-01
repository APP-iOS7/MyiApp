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
        public enum Delegate: Equatable {
            case editNameTapped(Baby)
        }

        case binding(BindingAction<State>)
        case delegate(Delegate)

        case nameRowTapped
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .nameRowTapped:
                .send(.delegate(.editNameTapped(state.baby)))

            case .binding, .delegate:
                .none
            }
        }
    }
}
