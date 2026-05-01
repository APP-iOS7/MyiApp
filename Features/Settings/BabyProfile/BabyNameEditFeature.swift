import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct BabyNameEditFeature {
    @ObservableState
    public struct State: Equatable {
        public var baby: Baby
        public var name: String
        public var isSaving: Bool = false
        @Presents public var alert: AlertState<Action.Alert>?

        public init(baby: Baby) {
            self.baby = baby
            name = baby.name
        }

        public var canSave: Bool {
            let trimmed = name.trimmingCharacters(in: .whitespaces)
            return !trimmed.isEmpty && trimmed != baby.name && !isSaving
        }
    }

    public enum Action: BindableAction {
        public enum Internal {
            case saveCompleted(Baby)
            case saveFailed(BabyError)
        }

        public enum Delegate: Equatable {
            case saved(Baby)
        }

        public enum Alert: Equatable {}

        case binding(BindingAction<State>)
        case alert(PresentationAction<Alert>)
        case _internal(Internal)
        case delegate(Delegate)

        case saveButtonTapped
    }

    @Dependency(\.babyClient) var babyClient

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .saveButtonTapped:
                guard state.canSave else { return .none }

                state.isSaving = true
                var updated = state.baby
                updated.name = state.name.trimmingCharacters(in: .whitespaces)
                return .run { [babyClient, updated] send in
                    do throws(BabyError) {
                        try await babyClient.updateBaby(updated)
                        await send(._internal(.saveCompleted(updated)))
                    } catch {
                        await send(._internal(.saveFailed(error)))
                    }
                }

            case let ._internal(.saveCompleted(baby)):
                state.isSaving = false
                return .send(.delegate(.saved(baby)))

            case ._internal(.saveFailed):
                state.isSaving = false
                state.alert = AlertState {
                    TextState("저장 실패")
                } message: {
                    TextState("이름을 저장하는 중 문제가 발생했어요. 잠시 후 다시 시도해주세요.")
                }
                return .none

            case .binding, .alert, .delegate:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
