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
        case binding(BindingAction<State>)
        case submitTapped
        case submitSucceeded
        case submitFailed(BabyError)
        case alert(PresentationAction<Alert>)
        case delegate(Delegate)

        public enum Alert: Equatable {}

        public enum Delegate: Equatable {
            case completed
        }
    }

    @Dependency(\.babyClient) var babyClient

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .submitTapped:
                guard state.isSubmitEnabled else { return .none }

                let code = state.inviteCode.trimmingCharacters(in: .whitespacesAndNewlines)
                state.isSubmitting = true

                return .run { [babyClient] send in
                    do throws(BabyError) {
                        try await babyClient.registerExistingBaby(code)
                        await send(.submitSucceeded)
                    } catch {
                        await send(.submitFailed(error))
                    }
                }

            case .submitSucceeded:
                state.isSubmitting = false
                return .send(.delegate(.completed))

            case let .submitFailed(error):
                state.isSubmitting = false
                state.alert = makeAlert(for: error)
                return .none

            case .alert, .delegate:
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
