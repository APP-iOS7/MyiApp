import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct BabyBirthDateEditFeature {
    @ObservableState
    public struct State: Equatable {
        public var baby: Baby
        public var birthDate: Date
        public var isSaving: Bool = false
        @Presents public var alert: AlertState<Action.Alert>?

        public init(baby: Baby) {
            self.baby = baby
            birthDate = baby.birthDate
        }

        public var canSave: Bool {
            birthDate != baby.birthDate && !isSaving
        }
    }

    public enum Action: BindableAction {
        public enum ViewAction {
            case saveButtonTapped
        }

        public enum InternalAction {
            case saveCompleted
            case saveFailed(BabyError)
        }

        public enum Alert: Equatable {}

        case view(ViewAction)
        case _internal(InternalAction)

        case binding(BindingAction<State>)
        case alert(PresentationAction<Alert>)
    }

    @Dependency(\.babyClient) var babyClient
    @Dependency(\.dismiss) var dismiss

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .view(.saveButtonTapped):
                guard state.canSave else { return .none }
                state.isSaving = true
                var updated = state.baby
                updated.birthDate = state.birthDate
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
                    TextState("출생일을 저장하는 중 문제가 발생했어요. 잠시 후 다시 시도해주세요.")
                }
                return .none

            case .binding, .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
