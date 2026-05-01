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
        public enum InternalAction {
            case saveCompleted
            case saveFailed(BabyError)
        }

        public enum Alert: Equatable {}

        case binding(BindingAction<State>)
        case saveButtonTapped
        case _internal(InternalAction)
        case alert(PresentationAction<Alert>)
    }

    @Dependency(\.babyClient) var babyClient
    @Dependency(\.dismiss) var dismiss

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .saveButtonTapped:
                guard state.canSave else { return .none }

                state.isSaving = true
                var updated = state.baby
                updated.name = state.name.trimmingCharacters(in: .whitespaces)
                return .run { [babyClient, updated] send in
                    do throws(BabyError) {
                        try await babyClient.updateBaby(updated)
                        await send(._internal(.saveCompleted))
                    } catch {
                        await send(._internal(.saveFailed(error)))
                    }
                }

            case ._internal(.saveCompleted):
                state.isSaving = false
                return .run { [dismiss] _ in await dismiss() }

            case ._internal(.saveFailed):
                state.isSaving = false
                state.alert = AlertState {
                    TextState("저장 실패")
                } message: {
                    TextState("이름을 저장하는 중 문제가 발생했어요. 잠시 후 다시 시도해주세요.")
                }
                return .none

            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
