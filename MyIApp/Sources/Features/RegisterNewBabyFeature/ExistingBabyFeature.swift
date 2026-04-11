import ComposableArchitecture
import Foundation

@Reducer
public struct ExistingBabyFeature: Sendable {
    @ObservableState
    public struct State: Equatable {
        public init() {}

        public var invitationCode: String = ""
        public var isLoading: Bool = false
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

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case submitButtonTapped
        case registrationResponse(Result<Bool, Error>)
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case registrationCompleted
        }

        public enum Error: Swift.Error, Equatable {
            case invalidCode
            case networkError
        }
    }

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

                // 실제 API 연동 전까지 모의 로딩 처리 (1초 대기)
                return .run { [code = state.invitationCode] send in
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    // "WELCOME" 또는 6자 이상의 코드면 성공으로 가정
                    if code.count >= 6 {
                        await send(.registrationResponse(.success(true)))
                    } else {
                        await send(.registrationResponse(.failure(.invalidCode)))
                    }
                }

            case .registrationResponse(.success):
                state.isLoading = false
                return .send(.delegate(.registrationCompleted))

            case let .registrationResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = "유효하지 않은 코드입니다. 다시 확인해 주세요."
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
