import ComposableArchitecture
import Domain

@Reducer
public struct AppFeature {
    @Reducer
    public enum Destination {
        case home(HomeFeature)
        case babyRegister(BabyRegisterFeature)
    }

    @ObservableState
    public struct State {
        public var auth: LoginFeature.State = .init()
        @Presents public var destination: Destination.State?

        public init() {}
    }

    public enum Action {
        case onAppear
        case sessionUpdated(Session?)
        case auth(LoginFeature.Action)
        case destination(PresentationAction<Destination.Action>)
    }

    @Dependency(\.authClient) var authClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.auth, action: \.auth) {
            LoginFeature()
        }
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.destination = makeDestination(for: authClient.current())
                return .run { [authClient] send in
                    for await session in authClient.stateStream() {
                        await send(.sessionUpdated(session))
                    }
                }

            case let .sessionUpdated(session):
                state.destination = makeDestination(for: session)
                return .none

            case .auth, .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }

    private func makeDestination(for session: Session?) -> Destination.State? {
        guard let session else { return nil }
        // TODO: BabyClient 합류 후 baby 존재 여부에 따라 .home / .babyRegister 분기
        _ = session
        return .babyRegister(BabyRegisterFeature.State())
    }
}
