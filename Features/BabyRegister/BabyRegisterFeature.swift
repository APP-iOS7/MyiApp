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
        public enum ViewAction {
            case methodSelected(Method)
            case nextTapped
        }

        public enum Delegate: Equatable {
            case proceedToNewBaby
            case proceedToExistingBaby
        }

        case view(ViewAction)
        case delegate(Delegate)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(.methodSelected(method)):
                state.selectedMethod = method
                return .none

            case .view(.nextTapped):
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
