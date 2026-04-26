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
        case deleteAccountTapped
        case actionResponse(Result<Void, any Error>)
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
                    do {
                        try await authClient.signOut()
                        await send(.actionResponse(.success(())))
                    } catch {
                        await send(.actionResponse(.failure(error)))
                    }
                }

            case .deleteAccountTapped:
                state.isProcessing = true
                state.errorMessage = nil
                return .run { [authClient] send in
                    do {
                        try await authClient.deleteAccount()
                        await send(.actionResponse(.success(())))
                    } catch {
                        await send(.actionResponse(.failure(error)))
                    }
                }

            case .actionResponse(.success):
                state.isProcessing = false
                return .none

            case let .actionResponse(.failure(error)):
                state.isProcessing = false
                state.errorMessage = error.localizedDescription
                return .none
            }
        }
    }
}
