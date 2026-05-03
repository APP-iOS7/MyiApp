import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct AccountEditFeature {
    @ObservableState
    public struct State: Equatable {
        public let originalName: String?
        public var name: String
        public var isSaving: Bool = false
        @Presents public var alert: AlertState<Action.Alert>?

        public init(originalName: String?) {
            self.originalName = originalName
            name = originalName ?? ""
        }

        public var canSave: Bool {
            let trimmed = name.trimmingCharacters(in: .whitespaces)
            return !trimmed.isEmpty && trimmed != originalName && !isSaving
        }
    }

    public enum Action: BindableAction {
        public enum ViewAction {
            case saveButtonTapped
        }

        public enum InternalAction {
            case saveCompleted
            case saveFailed(CaregiverError)
        }
        public enum Alert: Equatable {}

        case view(ViewAction)
        case _internal(InternalAction)

        case binding(BindingAction<State>)
        case alert(PresentationAction<Alert>)
    }

    @Dependency(\.caregiverClient) var caregiverClient
    @Dependency(\.dismiss) var dismiss

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .view(.saveButtonTapped):
                guard state.canSave else { return .none }
                state.isSaving = true
                let trimmed = state.name.trimmingCharacters(in: .whitespaces)
                return .run { [caregiverClient] send in
                    do throws(CaregiverError) {
                        try await caregiverClient.updateDisplayName(trimmed)
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

            case .binding, .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
