import Clients
import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct AuthFeature {
    @ObservableState
    public struct State: Equatable {
        public var isLoading: Bool = false
        public var errorMessage: String?

        public init() {}
    }

    public enum Action {
        case signInWithAppleTapped
        case signInWithGoogleTapped
        case signInSucceeded
        case signInFailed(AuthError)
    }

    @Dependency(\.authClient) var authClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .signInWithAppleTapped:
                state.isLoading = true
                state.errorMessage = nil
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
                state.errorMessage = nil
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
                state.errorMessage = Self.message(for: error)
                return .none
            }
        }
    }

    private static func message(for error: AuthError) -> String {
        switch error {
        case .requiresRecentLogin:
            "다시 로그인해주세요."
        case .unexpected:
            "로그인 중 문제가 발생했습니다. 잠시 후 다시 시도해주세요."
        }
    }
}
