import ComposableArchitecture
import Foundation

@Reducer
struct LoginFeature {
    @ObservableState
    struct State: Equatable {
        var isLoading: Bool = false
        var errorMessage: String?
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

        case view(ViewAction)
        case `internal`(InternalAction)
        case delegate(DelegateAction)
    }

    @Dependency(\.authClient) var authClient
    @Dependency(\.appleSignInClient) var appleSignInClient

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
                return .none

            case let .internal(.errorOccurred(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
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

            case .delegate:
                return .none
            }
        }
    }
}
