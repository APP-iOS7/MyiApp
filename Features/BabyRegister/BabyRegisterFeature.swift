import ComposableArchitecture
import Foundation

@Reducer
public struct BabyRegisterFeature {
    public enum Method: Equatable {
        case newBaby
        case existingBaby
    }

    @ObservableState
    public struct State: Equatable {
        public var selectedMethod: Method = .newBaby

        public init() {}
    }

    public enum Action {
        case methodSelected(Method)
        case nextTapped
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case proceedNewBaby
            case proceedExistingBaby
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .methodSelected(method):
                state.selectedMethod = method
                return .none

            case .nextTapped:
                switch state.selectedMethod {
                case .newBaby:
                    return .send(.delegate(.proceedNewBaby))
                case .existingBaby:
                    return .send(.delegate(.proceedExistingBaby))
                }

            case .delegate:
                return .none
            }
        }
    }
}
