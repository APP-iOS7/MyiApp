import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct ExistingBabyRegisterFeature {
    @ObservableState
    public struct State: Equatable {
        public var inviteCode: String = ""
        public var isSubmitting: Bool = false
        @Presents public var alert: AlertState<Action.Alert>?

        public init() {}

        public var isSubmitEnabled: Bool {
            !inviteCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && !isSubmitting
        }
    }

    public enum Action: BindableAction {
        public enum ViewAction {
            case submitTapped
        }

        public enum InternalAction {
            case submitSucceeded
            case submitFailed(BabyError)
        }

        public enum Delegate: Equatable {
            case completed
        }

        public enum Alert: Equatable {}

        case view(ViewAction)
        case _internal(InternalAction)
        case delegate(Delegate)

        case binding(BindingAction<State>)
        case alert(PresentationAction<Alert>)
    }

    @Dependency(\.babyClient) var babyClient

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .view(.submitTapped):
                guard state.isSubmitEnabled else { return .none }

                let code = state.inviteCode.trimmingCharacters(in: .whitespacesAndNewlines)
                guard let babyID = UUID(uuidString: code) else {
                    state.alert = makeAlert(for: .invalidInviteCode)
                    return .none
                }

                state.isSubmitting = true

                return .run { [babyClient] send in
                    do throws(BabyError) {
                        try await babyClient.registerExistingBaby(babyID)
                        await send(._internal(.submitSucceeded))
                    } catch {
                        await send(._internal(.submitFailed(error)))
                    }
                }

            case ._internal(.submitSucceeded):
                state.isSubmitting = false
                return .send(.delegate(.completed))

            case let ._internal(.submitFailed(error)):
                state.isSubmitting = false
                state.alert = makeAlert(for: error)
                return .none

            case .binding, .alert, .delegate:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }

    private func makeAlert(for error: BabyError) -> AlertState<Action.Alert> {
        AlertState {
            TextState("등록 실패")
        } message: {
            TextState(message(for: error))
        }
    }

    private func message(for error: BabyError) -> String {
        switch error {
        case .unauthorized:
            "로그인이 필요합니다."
        case .invalidInviteCode:
            "유효하지 않은 초대 코드입니다."
        case .unexpected:
            "등록 중 문제가 발생했습니다. 잠시 후 다시 시도해주세요."
        }
    }
}
