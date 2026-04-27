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
        public var session: Session?
        @Presents public var destination: Destination.State?

        public init() {}
    }

    public enum Action {
        case onAppear
        case sessionUpdated(Session?)
        case babiesFetched([Baby])
        case babiesFetchFailed(BabyError)
        case auth(LoginFeature.Action)
        case destination(PresentationAction<Destination.Action>)
    }

    @Dependency(\.authClient) var authClient
    @Dependency(\.babyClient) var babyClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.auth, action: \.auth) {
            LoginFeature()
        }
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { [authClient] send in
                    for await session in authClient.stateStream() {
                        await send(.sessionUpdated(session))
                    }
                }

            case let .sessionUpdated(session):
                state.session = session
                guard session != nil else {
                    state.destination = nil
                    return .none
                }
                return .run { [babyClient] send in
                    do throws(BabyError) {
                        let babies = try await babyClient.currentBabies()
                        await send(.babiesFetched(babies))
                    } catch {
                        await send(.babiesFetchFailed(error))
                    }
                }

            case let .babiesFetched(babies):
                guard let session = state.session else { return .none }
                if babies.isEmpty {
                    state.destination = .babyRegister(BabyRegisterFeature.State())
                } else {
                    state.destination = .home(HomeFeature.State(session: session))
                }
                return .none

            case .babiesFetchFailed:
                guard state.session != nil else { return .none }
                if state.destination == nil {
                    state.destination = .babyRegister(BabyRegisterFeature.State())
                }
                return .none

            case .destination(.presented(.babyRegister(.delegate(.babyRegistered)))):
                guard let session = state.session else { return .none }
                state.destination = .home(HomeFeature.State(session: session))
                return .none

            case .auth, .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }

}
