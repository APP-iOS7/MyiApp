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
        public enum DelegateAction: Equatable {
            case editNameTapped(Baby)
        }

        case binding(BindingAction<State>)
        case nameRowTapped
        case delegate(DelegateAction)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                .none

            case .nameRowTapped:
                .send(.delegate(.editNameTapped(state.baby)))

            case .delegate:
                .none
            }
        }
    }
}
