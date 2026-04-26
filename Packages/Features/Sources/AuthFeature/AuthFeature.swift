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
        case signInResponse(Result<Session, any Error>)
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
                    await send(.signInResponse(Result { try await authClient.signInWithApple() }))
                }

            case .signInWithGoogleTapped:
                state.isLoading = true
                state.errorMessage = nil
                return .run { [authClient] send in
                    await send(.signInResponse(Result { try await authClient.signInWithGoogle() }))
                }

            case .signInResponse(.success):
                state.isLoading = false
                return .none

            case let .signInResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
            }
        }
    }
}
