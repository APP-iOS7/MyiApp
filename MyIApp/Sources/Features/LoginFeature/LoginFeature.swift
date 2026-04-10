import ComposableArchitecture
import Foundation

@Reducer
struct LoginFeature {
    @ObservableState
    struct State: Equatable {
        var isLoading: Bool = false
        var errorMessage: String?
        @Presents var alert: AlertState<Action.Alert>?

        // 텍스트 상수
        let title: String = "My i"
        let subtitle: String = "쉽고 편한 육아 기록 앱"
        let googleButtonTitle: String = "Sign in with Google"
        let appleButtonTitle: String = "Sign in with Apple"
    }

    enum Action {
        enum ViewAction {
            case appleSignInButtonTapped
            case googleSignInButtonTapped
        }

        enum InternalAction {
            case credentialLoaded(OAuthCredential)
            case errorOccurred(Error)
        }

        enum DelegateAction {
            case signedIn(Session)
        }

        enum Alert: Equatable {}

        case view(ViewAction)
        case `internal`(InternalAction)
        case delegate(DelegateAction)
        case alert(PresentationAction<Alert>)
    }

    @Dependency(\.authClient) var authClient
    @Dependency(\.appleSignInClient) var appleSignInClient
    @Dependency(\.googleSignInClient) var googleSignInClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.appleSignInButtonTapped):
                state.isLoading = true
                return .run { send in
                    do {
                        let appleCredential = try await appleSignInClient.signIn()
                        await send(.internal(.credentialLoaded(appleCredential)))
                    } catch {
                        await send(.internal(.errorOccurred(error)))
                    }
                }

            case .view(.googleSignInButtonTapped):
                state.isLoading = true
                return .run { send in
                    do {
                        let googleCredential = try await googleSignInClient.signIn()
                        await send(.internal(.credentialLoaded(googleCredential)))
                    } catch {
                        await send(.internal(.errorOccurred(error)))
                    }
                }

            case let .internal(.errorOccurred(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                state.alert = AlertState {
                    TextState("로그인 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case let .internal(.credentialLoaded(credential)):
                return .run { send in
                    do {
                        let session = try await authClient.signIn(credential)
                        await send(.delegate(.signedIn(session)))
                    } catch {
                        await send(.internal(.errorOccurred(error)))
                    }
                }

            case .delegate, .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
