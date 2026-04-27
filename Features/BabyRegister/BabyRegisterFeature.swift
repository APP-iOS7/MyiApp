import ComposableArchitecture
import Foundation

@Reducer
public struct BabyRegisterFeature {
    public enum Method: Equatable {
        case newBaby
        case existingBaby
    }

    @Reducer
    public enum Path {
        case newBaby(NewBabyRegisterFeature)
        case existingBaby(ExistingBabyRegisterFeature)
    }

    @ObservableState
    public struct State {
        public var selectedMethod: Method = .newBaby
        public var path = StackState<Path.State>()

        public init() {}
    }

    public enum Action {
        case methodSelected(Method)
        case nextTapped
        case path(StackActionOf<Path>)
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
                    state.path.append(.newBaby(NewBabyRegisterFeature.State()))
                case .existingBaby:
                    state.path.append(.existingBaby(ExistingBabyRegisterFeature.State()))
                }
                return .none

            case .path(.element(id: _, action: .existingBaby(.delegate(.completed)))),
                 .path(.element(id: _, action: .newBaby(.delegate(.completed)))):
                state.path.removeAll()
                return .none

            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
