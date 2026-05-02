import ComposableArchitecture
import Foundation

@Reducer
public struct BabyRegisterFeature {
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
            case proceedToNewBaby
            case proceedToExistingBaby
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
                    return .send(.delegate(.proceedToNewBaby))
                case .existingBaby:
                    return .send(.delegate(.proceedToExistingBaby))
                }

            case .delegate:
                return .none
            }
        }
    }
}

extension BabyRegisterFeature {
    public enum Method: Equatable {
        case newBaby
        case existingBaby
    }
}
