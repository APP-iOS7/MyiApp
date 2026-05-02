import ComposableArchitecture
import Foundation

@Reducer
public struct BabyRegisterFlowFeature {
    @ObservableState
    public struct State: Equatable {
        public var picker = BabyRegisterFeature.State()
        public var path = StackState<Path.State>()

        public init() {}
    }

    public enum Action {
        case cancelTapped
        case picker(BabyRegisterFeature.Action)
        case path(StackActionOf<Path>)
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case babyRegistered
        }
    }

    @Dependency(\.dismiss) var dismiss

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.picker, action: \.picker) {
            BabyRegisterFeature()
        }
        Reduce { state, action in
            switch action {
            case .cancelTapped:
                return .run { [dismiss] _ in await dismiss() }

            case .picker(.delegate(.proceedToNewBaby)):
                state.path.append(.newBaby(NewBabyRegisterFeature.State()))
                return .none

            case .picker(.delegate(.proceedToExistingBaby)):
                state.path.append(.existingBaby(ExistingBabyRegisterFeature.State()))
                return .none

            case .path(.element(id: _, action: .newBaby(.delegate(.completed)))),
                 .path(.element(id: _, action: .existingBaby(.delegate(.completed)))):
                return .send(.delegate(.babyRegistered))

            case .picker, .path, .delegate:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension BabyRegisterFlowFeature {
    @Reducer
    public enum Path {
        case newBaby(NewBabyRegisterFeature)
        case existingBaby(ExistingBabyRegisterFeature)
    }
}

extension BabyRegisterFlowFeature.Path.State: Equatable {}
