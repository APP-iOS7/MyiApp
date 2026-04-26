import AuthFeature
import ComposableArchitecture
import Domain

@Reducer
public struct AppFeature {
    @ObservableState
    public struct State: Equatable {
        public var auth: AuthFeature.State = .init()
        public var home: HomeFeature.State?

        public init() {}
    }

    public enum Action {
        case onAppear
        case sessionUpdated(Session?)
        case auth(AuthFeature.Action)
        case home(HomeFeature.Action)
    }

    @Dependency(\.authClient) var authClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.auth, action: \.auth) {
            AuthFeature()
        }
        Reduce { state, action in
            switch action {
            case .onAppear:
                let initial = authClient.current()
                state.home = initial.map { HomeFeature.State(session: $0) }
                return .run { [authClient] send in
                    for await session in authClient.stateStream() {
                        await send(.sessionUpdated(session))
                    }
                }

            case let .sessionUpdated(session):
                state.home = session.map { HomeFeature.State(session: $0) }
                return .none

            case .auth, .home:
                return .none
            }
        }
        .ifLet(\.home, action: \.home) {
            HomeFeature()
        }
    }
}
