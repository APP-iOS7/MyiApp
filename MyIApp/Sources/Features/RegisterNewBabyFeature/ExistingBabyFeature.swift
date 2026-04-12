import ComposableArchitecture
import Foundation

@Reducer
public struct ExistingBabyFeature: Sendable {
    @ObservableState
    public struct State: Equatable, Sendable {
        public init() {}

        public var invitationCode: String = ""
        public var isLoading: Bool = false
        @Presents public var alert: AlertState<Alert>?
        public var errorMessage: String?

        // 텍스트 상수
        public let navigationTitle: String = "초대받은 아이 등록"
        public let sectionTitle: String = "초대 코드 입력"
        public let description: String = "이미 등록된 아이가 있다면 초대 코드를 입력해 주세요."
        public let placeholderCode: String = "초대 코드를 입력하세요"
        public let submitButtonTitle: String = "등록하기"

        public var isButtonEnabled: Bool {
            invitationCode.count >= 6 && !isLoading
        }
    }

    public enum Action: BindableAction, Equatable, Sendable {
        case binding(BindingAction<State>)
        case submitButtonTapped
        case registrationResponse(TaskResult<Baby>)
        case delegate(Delegate)
        case alert(PresentationAction<Alert>)
    }

    public enum Alert: Equatable, Sendable {}

    public enum Delegate: Equatable, Sendable {
        case registrationCompleted
    }

    @Dependency(\.babyClient) var babyClient

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.invitationCode):
                // 대문자로 자동 변환 (선택 사항이나 권장되는 UX)
                state.invitationCode = state.invitationCode.uppercased()
                return .none

            case .binding:
                return .none

            case .submitButtonTapped:
                state.isLoading = true
                state.errorMessage = nil

                return .run { [code = state.invitationCode] send in
                    await send(.registrationResponse(
                        TaskResult {
                            try await babyClient.registerExistingBaby(code)
                        }
                    ))
                }

            case .registrationResponse(.success):
                state.isLoading = false
                return .send(.delegate(.registrationCompleted))

            case let .registrationResponse(.failure(error)):
                state.isLoading = false
                state.alert = AlertState {
                    TextState("등록 실패")
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case .alert:
                return .none

            case .delegate:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
