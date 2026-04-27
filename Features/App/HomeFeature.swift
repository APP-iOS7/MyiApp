import Clients
import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct HomeFeature {
    @ObservableState
    public struct State: Equatable {
        public var session: Session
        public var isProcessing: Bool = false
        public var errorMessage: String?

        public init(session: Session) {
            self.session = session
        }
    }

    public enum Action {
        case signOutTapped
        case signOutSucceeded
        case signOutFailed(AuthError)
        case deleteAccountTapped
        case deleteAccountSucceeded
        case deleteAccountFailed(AuthError)
    }

    @Dependency(\.authClient) var authClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .signOutTapped:
                state.isProcessing = true
                state.errorMessage = nil
                return .run { [authClient] send in
                    do throws(AuthError) {
                        try await authClient.signOut()
                        await send(.signOutSucceeded)
                    } catch {
                        await send(.signOutFailed(error))
                    }
                }

            case .deleteAccountTapped:
                state.isProcessing = true
                state.errorMessage = nil
                return .run { [authClient] send in
                    do throws(AuthError) {
                        try await authClient.deleteAccount()
                        await send(.deleteAccountSucceeded)
                    } catch {
                        await send(.deleteAccountFailed(error))
                    }
                }

            case .signOutSucceeded, .deleteAccountSucceeded:
                state.isProcessing = false
                return .none

            case let .signOutFailed(error), let .deleteAccountFailed(error):
                state.isProcessing = false
                state.errorMessage = message(for: error)
                return .none
            }
        }
    }

    private func message(for error: AuthError) -> String {
        switch error {
        case .requiresRecentLogin:
            "최근 로그인이 필요합니다. 다시 로그인 후 시도해주세요."
        case .unexpected:
            "처리 중 문제가 발생했습니다. 잠시 후 다시 시도해주세요."
        }
    }
}
