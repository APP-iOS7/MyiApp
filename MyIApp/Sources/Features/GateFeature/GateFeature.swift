import ComposableArchitecture
import Foundation

@Reducer
struct GateFeature {
    @ObservableState
    enum State: Equatable {
        case loading
        case login(LoginFeature.State)
        case main
    }

    enum Action {
        enum ViewAction {
            case onAppear
            case logoutButtonTapped
        }

        enum InternalAction {
            case sessionLoaded(Session?)
            case signedOut
        }

        case view(ViewAction)
        case `internal`(InternalAction)
        case login(LoginFeature.Action)
    }

    @Dependency(\.authClient) var authClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                return .run { send in
                    let session = await authClient.currentSession()
                    await send(.internal(.sessionLoaded(session)))
                }

            case .view(.logoutButtonTapped):
                return .run { send in
                    try await authClient.signOut()
                    await send(.internal(.signedOut))
                }

            case let .internal(.sessionLoaded(session)):
                guard session != nil else {
                    state = .login(.init())
                    return .none
                }

                state = .main
                return .none

            case .internal(.signedOut):
                state = .login(.init())
                return .none

            case .login(.delegate(.signedIn)):
                state = .main
                return .none

            case .login:
                return .none
            }
        }
        .ifCaseLet(\.login, action: \.login) {
            LoginFeature()
        }
    }
}
