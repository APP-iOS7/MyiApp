import Clients
import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct LoginFeature {
    @ObservableState
    public struct State: Equatable {
        public var isLoading: Bool = false
        @Presents public var alert: AlertState<Action.Alert>?

        public init() {}
    }

    public enum Action {
        case signInWithAppleTapped
        case signInWithGoogleTapped
        case signInSucceeded
        case signInFailed(AuthError)
        case alert(PresentationAction<Alert>)

        public enum Alert: Equatable {}
    }

    @Dependency(\.authClient) var authClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .signInWithAppleTapped:
                state.isLoading = true
                return .run { [authClient] send in
                    do throws(AuthError) {
                        _ = try await authClient.signInWithApple()
                        await send(.signInSucceeded)
                    } catch {
                        await send(.signInFailed(error))
                    }
                }

            case .signInWithGoogleTapped:
                state.isLoading = true
                return .run { [authClient] send in
                    do throws(AuthError) {
                        _ = try await authClient.signInWithGoogle()
                        await send(.signInSucceeded)
                    } catch {
                        await send(.signInFailed(error))
                    }
                }

            case .signInSucceeded:
                state.isLoading = false
                return .none

            case let .signInFailed(error):
                state.isLoading = false
                state.alert = AlertState {
                    TextState("로그인 실패")
                } message: {
                    TextState(message(for: error))
                }
                return .none

            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }

    private func message(for error: AuthError) -> String {
        switch error {
        case .requiresRecentLogin:
            "다시 로그인해주세요."
        case .unexpected:
            "로그인 중 문제가 발생했습니다. 잠시 후 다시 시도해주세요."
        }
    }
}
