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
        public enum ViewAction {
            case task
            case signInWithAppleTapped
            case signInWithGoogleTapped
        }

        public enum InternalAction {
            case signInSucceeded
            case signInFailed(AuthError)
        }

        public enum Alert: Equatable {}

        case view(ViewAction)
        case _internal(InternalAction)

        case alert(PresentationAction<Alert>)
    }

    @Dependency(\.analytics) var analytics
    @Dependency(\.authClient) var authClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.task):
                return .run { [analytics] _ in analytics.trackScreen(.login) }

            case .view(.signInWithAppleTapped):
                state.isLoading = true
                return .run { [authClient] send in
                    do throws(AuthError) {
                        _ = try await authClient.signInWithApple()
                        await send(._internal(.signInSucceeded))
                    } catch {
                        await send(._internal(.signInFailed(error)))
                    }
                }

            case .view(.signInWithGoogleTapped):
                state.isLoading = true
                return .run { [authClient] send in
                    do throws(AuthError) {
                        _ = try await authClient.signInWithGoogle()
                        await send(._internal(.signInSucceeded))
                    } catch {
                        await send(._internal(.signInFailed(error)))
                    }
                }

            case ._internal(.signInSucceeded):
                state.isLoading = false
                return .none

            case let ._internal(.signInFailed(error)):
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
